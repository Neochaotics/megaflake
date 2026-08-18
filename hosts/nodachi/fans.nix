{
  pkgs,
  ...
}:
let
  # fanctl config: drive the case/CPU fans (it87/it8689 chip, hwmon) off the
  # GPU junction temperature. The stock it87 SmartFan curves only react to
  # board temps, so when the GPU is hot but the CPU/board is cool the case
  # fans stay low, trapping heat. Tying them to GPU junction exhausts hot air
  # harder during gaming/AI loads.
  fanctlConfig = pkgs.writeText "fanctl.yml" ''
    interval: 500
    log_iterations: 20

    inputs:
      gpu_junction:
        HwmonSensor:
          hwmon: amdgpu
          label: junction
      cpu_temp:
        HwmonSensor:
          hwmon: k10temp
          label: Tctl

    outputs:
      case_fan1:
        PwmFan:
          hwmon: it8689
          name: pwm1
      case_fan2:
        PwmFan:
          hwmon: it8689
          name: pwm2
      case_fan3:
        PwmFan:
          hwmon: it8689
          name: pwm3

    rules:
      - outputs:
          - case_fan1
          - case_fan2
          - case_fan3
        rule:
          Maximum:
            - Static: 0.35
            - Curve:
                input: gpu_junction
                keys:
                  - input: 30.0
                    output: 0.3
                  - input: 55.0
                    output: 0.6
                  - input: 75.0
                    output: 1.0
            - Curve:
                input: cpu_temp
                keys:
                  - input: 50.0
                    output: 0.4
                  - input: 70.0
                    output: 0.7
                  - input: 90.0
                    output: 1.0
  '';
in
{
  systemd.services.fanctl = {
    description = "fanctl case fan control (tied to GPU temp)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.fanctl}/bin/fanctl -c ${fanctlConfig}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
