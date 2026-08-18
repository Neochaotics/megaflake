# Final Plan — `nodachi` Performance & Thermal

## Status
- ✅ **Phase 3 done & committed** (`f889c53`): zram swap (priority 100) + `boot.tmp.useZram`; powertop auto-tune removed
- Remaining: Phase 0 → 1 → 2 → 4

## Phase 0 — Baseline (15 min, read-only diagnostics)
1. `sudo journalctl -b | grep -iE "amdgpu|thermal|throttl|shutdown"` — confirm overheat history
2. 5-min load (game or `glmark2`) + `watch -n1 amdgpu_top` → record peak junction/edge/mem + fan RPM
3. `nix shell nixpkgs#lact -c lact cli list-gpus` → capture `1002:73A5-...` GPU ID
4. `systemctl status power-profiles-daemon` — if active, add `--block-action=amdgpu_dpm` override for LACT

## Phase 1 — GPU thermal tuning (new `hosts/nodachi/gpu.nix`, imported from `default.nix`)
Native `services.lact` (daemon-only, no GUI, no new inputs):
- `voltage_offset: -50` (undervolt, Navi 2x), `power_cap: 260.0`
- Junction-based aggressive fan curve: `{ 45: 0.4, 60: 0.6, 75: 0.85, 90: 1.0 }`
- `Gaming` profile → `performance_level: manual, power_profile_mode_index: 1` (3D_FULL_SCREEN), gamemode-triggered, `auto_switch_profiles: true`
- `lactd` applies at boot + resume — no scripts

## Phase 2 — Gaming
- `environment.sessionVariables.RADV_PERFTEST = "transfer_queue"` in `home.nix` (Mesa 26 RDNA2 SDMA queues)
- Keep freedpom CachyOS sysctls; verify with `mangohud`

## Phase 2.5 — scx/sched-ext (DEFERRED for later testing, not enabled)
- Native module exists (`services.scx`), kernel supports it (`CONFIG_SCHED_CLASS_EXT=y`)
- **Decision: leave `enable = false`.** Rationale: 8-core homogeneous CPU + ananicy/gamemode/gamescope/CachyOS sysctls already cover latency tuning; scx wins are marginal-to-negative on 8 cores; freedpom doesn't use it.
- **When to revisit:** later, as an A/B experiment — as root run `nix shell nixpkgs#scx -c scx_bpfland` while gaming, measure FPS/1% lows vs EEVDF, only commit if it wins.

## Phase 4 — Verify & commit
1. Re-run load test → junction ≤85°C (vs. ~110°C), fan responding, no throttle
2. `nix flake check` + `nix build .#nixosConfigurations.nodachi.config.system.build.toplevel`
3. Reboot → `journalctl -u lactd` confirms applied values
4. Iterate: stable → `-75mV`; still hot → `power_cap: 240`
5. Commits: `feat(nodachi): add lact gpu tuning` + `perf(nodachi): enable radv transfer queue`

**Files:** `hosts/nodachi/gpu.nix` (new), `hosts/nodachi/home.nix`. No flake.lock changes.