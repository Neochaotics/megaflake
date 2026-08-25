{
  lib,
  stdenv,
  writeShellScriptBin,
  glmark2,
  clpeak,
}:

let
  # GPU benchmark runner for the RX 6950 XT on nodachi.
  # Runs compute (clpeak) and graphics (glmark2 offscreen) loads while
  # sampling the dGPU hwmon, capturing each tool's score output and the
  # peak live core clock. Hard-aborts if junction exceeds the safety limit.
  benchScript = writeShellScriptBin "bench" ''
    set -u

    GLMARK2="${glmark2}/bin/glmark2-gbm"
    CLPEAK="${clpeak}/bin/clpeak"

    # Safety: hard-abort the load if junction exceeds this (millidegrees C).
    ABORT_JUNCTION=$((95 * 1000))

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
      local out_txt="''${OUT}.txt"
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
      echo "=== $name DONE: junc=$((peak_junc/1000))C edge=$((peak_edge/1000))C pwr=$((peak_pwr/1000000))W clk=$((peak_clk/1000000))MHz cap=$((peak_cap/1000000))W ==="
    }

    # 1. Compute load on the dGPU (device 0 = gfx1030). Output captured so
    #    GFLOPS can be compared between profiles.
    run_load "clpeak" "$CLPEAK" --cl-device 0
    grep -E "float |half |Clock frequency|bandwidth \(GBPS\)" "$OUT.txt" | sed 's/^/[clpeak] /' | tee -a "$OUT"
    echo "" >> "$OUT"

    # Cooldown between the two tests.
    echo "Cooling down for 30s..." >> "$OUT"
    sleep 30

    # 2. Graphics load (offscreen EGL at native res).
    run_load "glmark2" "$GLMARK2" --off-screen -s 2560x1440
    grep "glmark2 Score" "$OUT.txt" | sed 's/^/[glmark2] /' | tee -a "$OUT"

    echo "=== BENCH COMPLETE $(date +%H:%M:%S) ===" >> "$OUT"
    echo "Done. Full log: $OUT (+ captured .txt outputs)"
  '';
in
stdenv.mkDerivation {
  pname = "bench";
  version = "2.0.0";

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
    description = "GPU thermal/performance benchmark runner with score capture and safety abort";
    license = lib.licenses.gpl3;
  };
}
