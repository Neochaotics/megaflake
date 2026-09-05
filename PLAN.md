# `nodachi` GPU Thermal & Performance — Outcome

## Problem
The Sapphire Nitro+ RX 6950 XT repeatedly hit **Critical Thermal Fault (SW CTF) shutdowns**
under sustained compute/gaming. Kernel log: `amdgpu: GPU over temperature range(SW CTF) detected`.

## Diagnosis
- Junction spiked ~48C -> ~110C within 2 seconds under load regardless of settings.
- Fan curve + power cap were working, but junction stayed ~110C even at only ~192-255W.
- Conclusion: **dried-out 2022 thermal paste** prevented die->heatsink heat transfer.

## Fixes applied
1. **Repaste** (physical) — the definitive fix.
2. **LACT** (`hosts/nodachi/gpu.nix`): undervolt `-100mV`, power cap `255W`
   (hardware floor), junction-based fan curve, three profiles:
   - **Default** (always): −100mV / 255W / auto fan curve
   - **Gaming** (gamemode-triggered): −100mV / 325W / 3D_FULL_SCREEN power profile / manual perf
   - **Compute** (manual): −100mV / 255W / COMPUTE power profile (index 5)
   Daemon uses writable config dir (`LACT_DAEMON_CONFIG_DIR=/var/lib/lact`).
   `amdgpu.ppfeaturemask=0xffffffff` for full overdrive access.
3. **zram swap** (priority 100) + `boot.tmp.useZram`, powertop removed
   (`f889c53`).
4. Case-fan control via `fanctl` was attempted and **reverted** — the
   IT8689/it87 chip ignores manual PWM writes on this board.
5. `scx`/sched-ext deferred (marginal benefit on 8-core homogeneous CPU).
6. `RADV_PERFTEST=transfer_queue` added to session env for Vulkan perf.
7. **BIOS Curve Optimizer −20 all-core** — held 4.91 GHz all-core under
   stress-ng (vs ~4.6–4.75 GHz stock). ryzen-smu module was loaded but
   exposed no debugfs on Raphael; removed as dead weight.

## GPU tuning outcomes (bench v3 matrix)

### Core overclock — DROPPED
| Metric | Default (−100/255) | Gaming (2725/−85/284) | Delta |
|---|---|---|---|
| glmark2 Score | 11547 | 11562 | +0.13% (noise) |
| clpeak float | 22523 GFLOPS | 21610 GFLOPS | **−4%** |
| Conclusion | — | — | No gain, compute regressed. RDNA2 core OC not viable on this silicon. |

### VRAM overclock — REVERTED
| Metric | Stock (1124 MHz) | +50 (1174 MHz) | +75 (1199 MHz) |
|---|---|---|---|
| clpeak BW | 509 GB/s | 529 GB/s (+4%) | — |
| Artifacts | None | None | **Black bars (unstable)** |
| Conclusion | — | Marginally stable | Unstable. Not worth the risk. |

### Final config
| Setting | Desktop | Gaming |
|---|---|---|
| Voltage offset | −100 mV | −100 mV |
| Power cap | 255 W | 325 W |
| MCLK | 1124 MHz (stock) | 1124 MHz (stock) |
| Core clocks | Stock | Stock |
| Power profile | Default | 3D_FULL_SCREEN |
| Fan curve | Junction-based | Junction-based |

### Thermal results (post-repaste)

| Load | Pre-repaste | Post-repaste |
|---|---|---|
| clpeak (compute) | 110°C (abort) | **57–68°C** |
| glmark2 (GL) | 109°C (abort) | **47–55°C** |
| Stress-ng 16-thread | — | 4.91 GHz sustained (CO −20) |

## Bench infrastructure
- `nix run .#bench` — bench v3: glmark2 offscreen + clpeak compute, hwmon
  sampling, 95°C safety abort, structured `SUMMARY:` line for easy comparison
- `BENCH_COOLDOWN` env var to shorten cooldown between tests
- Per-test `.txt` output files retained alongside the main log

## Hyprland HDR + Gaming

### Monitor
- LG ULTRAGEAR 2560×1440@120 (DP-2), HDR10 (PQ/ST2084), FreeSync
- `bitdepth, 10` — 10-bit output for HDR when auto-switch activates
- `cm, auto` — desktop stays SDR; `cm_auto_hdr` switches to HDR only for fullscreen games
- `vrr, 3` — FreeSync force mode (fullscreen game/video content)

### Hyprland render settings
- `cm_auto_hdr = 1` — auto-switch to HDR in fullscreen game content (reverts on exit)
- `direct_scanout = 2` — low-latency direct scanout (auto, game content only)
- `use_fp16 = 2` — fp16 buffers in HDR mode
- `quirks.prefer_hdr = 2` — gamescope-only HDR (avoids whitescreen/flicker)
- `sdrBrightness = 1.2`, `sdrSaturation = 0.98` — SDR tone tuning when HDR is active

### Gamescope HDR
- `programs.gamescope.enableWsi = true` — enables Vulkan WSI layer for native HDR games
- Launch options for HDR games:
  ```
  gamescope -f -e --hdr-enabled --hdr-itm-enabled --hdr-itm-target-nits 400 --expose-wayland -- %command%
  ```
- `--hdr-itm-target-nits 400` — HDR400 panel peak luminance
- If a game looks washed out with `--hdr-enabled`, drop to `--hdr-itm-enabled` only (SDR→HDR upconversion for punch without tone-mapping)

### Known limitations
- HDR400 panels have modest HDR quality (edge-lit, 400 nits, no local dimming) — true HDR games may look flatter than SDR; gamescope ITM usually produces better results
- gamescope SDR-blowout bug (#2331) affects ITM
- 10-bit may break some screen capture tools
- ICC profiles are "fundamentally incompatible with HDR gaming" — do not use

## Files
- `hosts/nodachi/gpu.nix` — LACT config (raw YAML), systemd service override
- `hosts/nodachi/hardware.nix` — kernel modules (it87), ppfeaturemask, kernel params, DP-2 display config (10-bit, auto CM)
- `hosts/nodachi/home.nix` — RADV_PERFTEST env var
- `hosts/nodachi/default.nix` — gamemode, gamescope WSI
- `modules/home-manager/hyprland/misc.nix` — render/quirks (HDR, direct scanout, VRR)
- `pkgs/bench/package.nix` — benchmark runner
- `/var/lib/lact/config.yaml` — runtime LACT config (writable, preStart reseeds)
