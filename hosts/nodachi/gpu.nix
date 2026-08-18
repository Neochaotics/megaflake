{
  pkgs,
  ...
}:
let
  # Raw YAML for LACT. Nix attrsets can only have string keys, so both
  # builtins.toJSON and pkgs.formats.yaml emit the fan-curve keys quoted
  # ('45' / "45"), which LACT's serde rejects (expects unquoted i32 keys).
  # A hand-written YAML string emits them as bare integers (45), which LACT
  # parses correctly.
  lactConfig = pkgs.writeText "lact-config.yaml" ''
    daemon:
      log_level: warn

    gpus:
      1002:73A5-1DA2:441D-0000:03:00.0:
        # -50 mV undervolt: big junction temp reduction, negligible perf loss
        voltage_offset: -50
        # Power cap 284W -> 260W: less sustained heat, ~2-3% perf cost max
        power_cap: 260.0
        # Custom aggressive fan curve driven by junction (hotspot) temp.
        # LACT's default passive curve lets the card reach 107C before the
        # fan responds; this spins it up early to keep junction under control.
        fan_control_enabled: true
        fan_control_settings:
          mode: curve
          temperature_key: junction
          interval_ms: 500
          curve:
            45: 0.4
            60: 0.6
            75: 0.85
            90: 1.0

    profiles:
      Gaming:
        gpus:
          1002:73A5-1DA2:441D-0000:03:00.0:
            performance_level: manual
            power_profile_mode_index: 1
        rule:
          type: gamemode

    auto_switch_profiles: true
  '';
in
{
  # LACT daemon applies the undervolt, power cap, and aggressive fan curve at
  # boot and re-applies them on suspend/resume. Needed to stop the RX 6950 XT
  # from hitting a critical thermal fault (SW CTF) under sustained compute/gaming.
  services.lact = {
    enable = true;
    settings = { };
  };

  # LACT 0.10+ writes its config on startup (settings application /
  # migrate_versions), but /etc is read-only on NixOS so the default
  # /etc/lact/config.yaml is an immutable store symlink and the write fails.
  # Redirect the config dir to a writable location via the upstream
  # LACT_DAEMON_CONFIG_DIR env var and seed it from the baked config.
  systemd.services.lactd = {
    serviceConfig = {
      StateDirectory = "lact";
      Environment = "LACT_DAEMON_CONFIG_DIR=/var/lib/lact";
    };
    preStart = ''
      mkdir -p /var/lib/lact
      cp -f ${lactConfig} /var/lib/lact/config.yaml
      rm -f /run/lactd.sock
    '';
  };
}
