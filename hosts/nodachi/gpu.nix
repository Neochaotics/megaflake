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
        # -100 mV undervolt: efficiency. After repasting, clpeak peak junction
        # dropped from 110C to 77C, so this is comfortable margin.
        voltage_offset: -100
        # 255W is the hardware floor (power1_cap_min); the driver clamps any
        # lower request up to it. Efficient/silent for desktop and compute.
        power_cap: 255.0
        # Moderate fan curve on junction (hotspot). Repaste means the old
        # aggressive curve is no longer needed for desktop idle.
        fan_control_enabled: true
        fan_control_settings:
          mode: curve
          temperature_key: junction
          interval_ms: 500
          curve:
            45: 0.35
            60: 0.6
            75: 0.9
            90: 1.0

    profiles:
      Gaming:
        gpus:
          1002:73A5-1DA2:441D-0000:03:00.0:
            # IMPORTANT: LACT profiles replace the whole GPU config, so the
            # thermal protections MUST be repeated here or they'd be dropped
            # while gaming (the exact worst time).
            # Measured (bench v2 matrix): raising max_core_clock to 2725 with
            # -85 mV gave +0.13% graphics score and -4% compute throughput,
            # so clocks stay stock; the profile exists purely to grant extra
            # power headroom while keeping the proven -100 mV undervolt.
            # 325W: card TBP spec is 335W (sysfs max 340W); post-repaste
            # junction stays <80C at full load — large margin to the 95C
            # bench-abort line.
            voltage_offset: -100
            power_cap: 325.0
            fan_control_enabled: true
            fan_control_settings:
              mode: curve
              temperature_key: junction
              interval_ms: 500
              curve:
                45: 0.35
                60: 0.6
                75: 0.9
                90: 1.0
            performance_level: manual
            power_profile_mode_index: 1
        rule:
          type: gamemode

      Compute:
        gpus:
          1002:73A5-1DA2:441D-0000:03:00.0:
            # Compute profile for AI/OpenCL workloads. power_profile_mode 5
            # optimizes GPU power management for sustained compute throughput
            # rather than bursty graphics. Same undervolt + 255W cap as
            # desktop — compute doesn't need the gaming profile's 325W headroom.
            voltage_offset: -100
            power_cap: 255.0
            fan_control_enabled: true
            fan_control_settings:
              mode: curve
              temperature_key: junction
              interval_ms: 500
              curve:
                45: 0.35
                60: 0.6
                75: 0.9
                90: 1.0
            performance_level: manual
            power_profile_mode_index: 5
        rule:
          type: manual

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
  #
  # PATH: the stock unit PATH lacks sudo/busctl, which LACT requires to talk
  # to gamemoded over its session bus for automatic profile switching
  # (otherwise profiles silently never activate).
  systemd.services.lactd = {
    serviceConfig = {
      StateDirectory = "lact";
      Environment = [
        "LACT_DAEMON_CONFIG_DIR=/var/lib/lact"
        "PATH=/run/current-system/sw/bin"
      ];
    };
    preStart = ''
      mkdir -p /var/lib/lact
      cp -f ${lactConfig} /var/lib/lact/config.yaml
      rm -f /run/lactd.sock
    '';
  };
}
