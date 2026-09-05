{
  lib,
  stdenv,
  writeShellScriptBin,
  glmark2,
  clpeak,
}:

let
  # GPU benchmark runner v3 for the RX 6950 XT on nodachi.
  # Runs compute (clpeak) and graphics (glmark2 offscreen) loads while
  # sampling the dGPU hwmon. Outputs a one-line SUMMARY with all key
  # metrics in key=value format for easy run-to-run comparison.
  benchScript = writeShellScriptBin "bench" ''
    set -u

    GLMARK2="${glmark2}/bin/glmark2-gbm"
    CLPEAK="${clpeak}/bin/clpeak"

    # Safety: hard-abort the load if junction exceeds this (millidegrees C).
    ABORT_JUNCTION=$((95 * 1000))

    # Cooldown between tests (seconds). Override with BENCH_COOLDOWN env var.
    COOLDOWN="''${BENCH_COOLDOWN:-30}"

    # Locate the dGPU hwmon dir (amdgpu with a junction sensor).
    HWMON=""
    for d in /sys/class/drm/card*/device; do
      for h in "$d"/hwmon/hwmon*; do
        if [ -e "$h/temp2_input" ] && [ "$(cat "$h/name" 2>/dev/null)" = "amdgpu" ]; then
          HWMON="$h"
        fi
      done
      [ -n "$HWMON" ] && break
    done
    [ -z "$HWMON" ] && { echo "ERROR: could not locate amdgpu hwmon"; exit 1; }
    echo "Using hwmon: $HWMON"
    DEV="$(dirname "$HWMON")"

    OUT="$1"
    if [ -z "$OUT" ]; then
      OUT="/tmp/bench-$(date +%Y%m%d-%H%M%S).log"
    fi
    echo "Logging to: $OUT"
    : > "$OUT"

    run_load() {
      local name="$1"; shift
      local bin="$1"; shift
      local out_txt="''${OUT}.$name.txt"
      : > "$out_txt"
      echo "=== $name START $(date +%H:%M:%S) ===" >> "$OUT"
      ( "$bin" "$@" > "$out_txt" 2>&1 ) &
      local LOAD_PID=$!
      local peak_junc=0 peak_edge=0 peak_fan=0 peak_pwr=0 peak_clk=0 peak_cap=0
      while kill -0 "$LOAD_PID" 2>/dev/null; do
        local J E M F P U C CAP
        J=$(cat "$HWMON/temp2_input" 2>/dev/null || echo 0)
        E=$(cat "$HWMON/temp1_input" 2>/dev/null || echo 0)
        M=$(cat "$HWMON/temp3_input" 2>/dev/null || echo 0)
        F=$(cat "$HWMON/fan1_input" 2>/dev/null || echo 0)
        P=$(cat "$HWMON/power1_average" 2>/dev/null || echo 0)
        U=$(cat "$DEV/gpu_busy_percent" 2>/dev/null || echo 0)
        C=$(cat "$DEV/freq1_input" 2>/dev/null || echo 0)
        CAP=$(cat "$HWMON/power1_cap" 2>/dev/null || echo 0)
        [ "$J" -gt "$peak_junc" ] && peak_junc=$J
        [ "$E" -gt "$peak_edge" ] && peak_edge=$E
        [ "$F" -gt "$peak_fan" ] && peak_fan=$F
        [ "$P" -gt "$peak_pwr" ] && peak_pwr=$P
        [ "$C" -gt "$peak_clk" ] && peak_clk=$C
        [ "$CAP" -gt "$peak_cap" ] && peak_cap=$CAP
        echo "$(date +%H:%M:%S) edge=$E junc=$J mem=$M fan=$F pwr=$P util=$U clk=$((C/1000000))MHz cap=$((CAP/1000000))W" >> "$OUT"
        if [ "$J" -gt "$ABORT_JUNCTION" ]; then
          echo "!! ABORT: junction exceeded at $(date +%H:%M:%S)" >> "$OUT"
          echo "!! ABORTED $name (junction $((J/1000))C) at $(date +%H:%M:%S)"
          kill "$LOAD_PID" 2>/dev/null
          wait "$LOAD_PID" 2>/dev/null
          echo "=== $name ABORTED: peak junc=$peak_junc edge=$peak_edge fan=$peak_fan pwr=$peak_pwr clk=$peak_clk cap=$peak_cap ===" >> "$OUT"
          return 1
        fi
        sleep 2
      done
      wait "$LOAD_PID" 2>/dev/null
      echo "=== $name DONE: peak junc=$peak_junc edge=$peak_edge fan=$peak_fan pwr=$peak_pwr clk=$peak_clk cap=$peak_cap ===" >> "$OUT"
    }

    # 1. Compute load on the dGPU (device 0 = gfx1030).
    run_load "clpeak" "$CLPEAK" --cl-device 0
    grep -E "float |half |Clock frequency|bandwidth \(GBPS\)" "$OUT.clpeak.txt" | sed 's/^/[clpeak] /' | tee -a "$OUT"
    echo "" >> "$OUT"

    # Cooldown between the two tests.
    echo "Cooling down for ''${COOLDOWN}s..." >> "$OUT"
    sleep "$COOLDOWN"

    # 2. Graphics load (offscreen EGL at native res).
    run_load "glmark2" "$GLMARK2" --off-screen -s 2560x1440
    grep "glmark2 Score" "$OUT.glmark2.txt" | sed 's/^/[glmark2] /' | tee -a "$OUT"

    # Extract metrics for structured summary.
    CLPEAK_FLOAT=$(grep "float    :" "$OUT.clpeak.txt" | head -1 | awk '{print $NF}')
    CLPEAK_HALF=$(grep "half     :" "$OUT.clpeak.txt" | head -1 | awk '{print $NF}')
    CLPEAK_BW=$(grep -A1 "Global memory bandwidth" "$OUT.clpeak.txt" | grep "float" | awk '{print $NF}')
    CLPEAK_LOCAL=$(grep -A1 "Local memory bandwidth" "$OUT.clpeak.txt" | grep "float" | awk '{print $NF}')
    GLMARK_SCORE=$(grep "glmark2 Score" "$OUT.glmark2.txt" | awk '{print $NF}')

    # Peak values from hwmon sampling.
    CLPEAK_DONE=$(grep "clpeak DONE" "$OUT" | tail -1)
    GLMARK_DONE=$(grep "glmark2 DONE" "$OUT" | tail -1)
    JUNC_MAX=$(echo "$CLPEAK_DONE" | sed 's/.*peak junc=\([0-9]*\).*/\1/' | head -1)
    PWR_MAX=$(echo "$CLPEAK_DONE" | sed 's/.*pwr=\([0-9]*\).*/\1/' | head -1)
    CAP_LIVE=$(echo "$GLMARK_DONE" | sed 's/.*cap=\([0-9]*\).*/\1/' | head -1)
    JUNC_GM=$(echo "$GLMARK_DONE" | sed 's/.*peak junc=\([0-9]*\).*/\1/' | head -1)

    echo "" >> "$OUT"
    echo "=== BENCH COMPLETE $(date +%H:%M:%S) ===" >> "$OUT"

    # Structured summary — one line, grep-friendly.
    echo "SUMMARY: glmark2=''${GLMARK_SCORE:-0} clpeak_float=''${CLPEAK_FLOAT:-0} clpeak_half=''${CLPEAK_HALF:-0} clpeak_bw=''${CLPEAK_BW:-0} clpeak_local=''${CLPEAK_LOCAL:-0} junc_clpeak=''${JUNC_MAX:-0} junc_glmark=''${JUNC_GM:-0} pwr_max=''${PWR_MAX:-0} cap=''${CAP_LIVE:-0}" | tee -a "$OUT"
    echo "Done. Full log: $OUT"
  '';
in
stdenv.mkDerivation {
  pname = "bench";
  version = "3.0.0";

  nativeBuildInputs = [ benchScript ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp "${benchScript}"/bin/bench $out/bin/bench
    chmod +x $out/bin/bench
    runHook postInstall
  '';

  meta = {
    description = "GPU benchmark runner with structured summary for run-to-run comparison";
    license = lib.licenses.gpl3;
  };
}
