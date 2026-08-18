{
  lib,
  stdenv,
  writeShellScriptBin,
  glmark2,
  clpeak,
}:

let
  # GPU hwmon directory for the RX 6950 XT (Sapphire Nitro+). Resolved by
  # PCI device ID at runtime, falling back to card1 which is the dGPU on nodachi.
  benchScript = writeShellScriptBin "bench" ''
    set -u

    GLMARK2="${glmark2}/bin/glmark2-gbm"
    CLPEAK="${clpeak}/bin/clpeak"

    # Safety: hard-abort the load if junction exceeds this (millidegrees C).
    ABORT_JUNCTION=$((95 * 1000))

    # Locate the dGPU hwmon dir by device name (amdgpu with a junction sensor).
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

    OUT="$1"
    if [ -z "$OUT" ]; then
      OUT="/tmp/bench-$(date +%Y%m%d-%H%M%S).log"
    fi
    echo "Logging to: $OUT"
    : > "$OUT"

    run_load() {
      local name="$1"; shift
      local bin="$1"; shift
      echo "=== $name START $(date +%H:%M:%S) ===" >> "$OUT"
      ( "$bin" "$@" >/dev/null 2>&1 ) &
      local LOAD_PID=$!
      local peak_junc=0 peak_edge=0 peak_fan=0 peak_pwr=0
      while kill -0 "$LOAD_PID" 2>/dev/null; do
        local J E M F P U
        J=$(cat "$HWMON/temp2_input" 2>/dev/null || echo 0)
        E=$(cat "$HWMON/temp1_input" 2>/dev/null || echo 0)
        M=$(cat "$HWMON/temp3_input" 2>/dev/null || echo 0)
        F=$(cat "$HWMON/fan1_input" 2>/dev/null || echo 0)
        P=$(cat "$HWMON/power1_average" 2>/dev/null || echo 0)
        U=$(cat "$(dirname "$HWMON")/gpu_busy_percent" 2>/dev/null || echo 0)
        [ "$J" -gt "$peak_junc" ] && peak_junc=$J
        [ "$E" -gt "$peak_edge" ] && peak_edge=$E
        [ "$F" -gt "$peak_fan" ] && peak_fan=$F
        [ "$P" -gt "$peak_pwr" ] && peak_pwr=$P
        echo "$(date +%H:%M:%S) edge=$E junc=$J mem=$M fan=$F pwr=$P util=$U" >> "$OUT"
        if [ "$J" -gt "$ABORT_JUNCTION" ]; then
          echo "!! ABORT: junction $J exceeds at $(date +%H:%M:%S)" >> "$OUT"
          echo "!! ABORTED $name (junction $((J/1000))C) at $(date +%H:%M:%S)"
          kill "$LOAD_PID" 2>/dev/null
          wait "$LOAD_PID" 2>/dev/null
          echo "=== $name ABORTED: peak junc=$peak_junc edge=$peak_edge fan=$peak_fan pwr=$peak_pwr ===" >> "$OUT"
          return 1
        fi
        sleep 2
      done
      wait "$LOAD_PID" 2>/dev/null
      echo "=== $name DONE: peak junc=$peak_junc edge=$peak_edge fan=$peak_fan pwr=$peak_pwr ===" >> "$OUT"
      echo "=== $name DONE: peak junc=$((peak_junc/1000))C edge=$((peak_edge/1000))C fan=$peak_fan RPM pwr=$((peak_pwr/1000000))W ==="
      return 0
    }

    # 1. GLmark2 off-screen (moderate load, ~50% util)
    run_load "glmark2" "$GLMARK2" --off-screen -s 2560x1440
    echo "" >> "$OUT"

    # 2. clpeak (compute/AI load, the CTF-inducing workload)
    run_load "clpeak" "$CLPEAK"

    echo "=== BENCH COMPLETE $(date +%H:%M:%S) ===" >> "$OUT"
    echo "Done. Full log: $OUT"
  '';
in
stdenv.mkDerivation {
  pname = "bench";
  version = "1.0.0";

  nativeBuildInputs = [ benchScript ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r "${benchScript}"/bin/bench $out/bin/bench
    chmod +x $out/bin/bench
    runHook postInstall
  '';

  meta = {
    description = "GPU thermal benchmark runner (glmark2 + clpeak) with safety abort";
    license = lib.licenses.gpl3;
  };
}
