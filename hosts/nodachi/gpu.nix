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
        # -100 mV undervolt: reduces junction temp on a card with degraded
        # thermal paste (still hits ~111C at only 195W). ~5-10% perf cost on
        # sustained compute but keeps it safe until repaste.
        voltage_offset: -100
        # Power cap 284W -> 240W: less sustained heat. Keep lower than ideal
        # given the card's cooling is degraded.
        power_cap: 240.0
        # Aggressive fan curve driven by junction (hotspot) temp. Ramp hard
        # and early; the stock passive curve let the card hit 107C.
        fan_control_enabled: true
        fan_control_settings:
          mode: curve
          temperature_key: junction
          interval_ms: 500
          curve:
            40: 0.5
            55: 0.75
            70: 1.0

    profiles:
      Gaming:
        gpus:
          1002:73A5-1DA2:441D-0000:03:00.0:
            # IMPORTANT: LACT profiles replace the whole GPU config, so the
            # thermal protections MUST be repeated here or they'd be dropped
            # while gaming (the exact worst time).
            voltage_offset: -100
            power_cap: 240.0
            fan_control_enabled: true
            fan_control_settings:
              mode: curve
              temperature_key: junction
              interval_ms: 500
              curve:
                40: 0.5
                55: 0.75
                70: 1.0
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
