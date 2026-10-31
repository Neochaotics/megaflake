{ config, inputs, ... }:
let
  constants = config.constants;
in
{
  imports = [ inputs.paseo.nixosModules.paseo ];

  # Runs as the interactive user so the agent CLIs it drives (opencode here)
  # and their config/auth are reachable from the daemon's PATH.
  services.paseo = {
    enable = true;
    user = constants.username;
    dataDir = "${constants.home}/.paseo";
    inheritUserEnvironment = true;
    listenAddress = "127.0.0.1";
    port = 6767;
    relay.enable = true;
  };
}
