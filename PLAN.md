# `nodachi` GPU Thermal & Performance — Outcome

## Problem
The Sapphire Nitro+ RX 6950 XT repeatedly hit **Critical Thermal Fault (SW CTF) shutdowns**
under sustained compute/gaming. Kernel log: `amdgpu: GPU over temperature range(SW CTF) detected`.

## Diagnosis
- Junction spiked ~48C -> ~110C within 2 seconds under load regardless of settings.
- Fan curve + power cap were working, but junction stayed ~110C even at only ~192-255W.
- Conclusion: **dried-out 2022 thermal paste** prevented die->heatsink heat transfer.

## Fixes applied (committed)
1. **Repaste** (physical) — the definitive fix.
2. **LACT** (`hosts/nodachi/gpu.nix`): undervolt `-100mV`, power cap `255W`
   (hardware floor), aggressive junction-based fan curve, gamemode Gaming
   profile carrying all thermal protections. Daemon run against a writable
   config dir (`LACT_DAEMON_CONFIG_DIR=/var/lib/lact`) because LACT writes
   its config on startup and `/etc` is read-only on NixOS.
3. **zram swap** (priority 100) + `boot.tmp.useZram`, powertop removed
   (`f889c53`).
4. Case-fan control via `fanctl` was attempted and **reverted** — the
   IT8689/it87 chip ignores manual PWM writes on this board.
5. `scx`/sched-ext deferred (marginal benefit on 8-core homogeneous CPU).

## Measured result (identical `nix run .#bench` before/after)

| Load | Pre-repaste junction | Post-repaste junction |
|---|---|---|
| clpeak (compute) | 110C (abort) | **77C** |
| glmark2 (GL) | 109C (abort) | **61C** |

Post-repaste the GPU fan stays in zero-RPM mode even at full 255W load.