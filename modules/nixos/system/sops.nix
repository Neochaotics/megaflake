{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.cm.nixos.system.sops;
in
{

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.cm.nixos.system.sops = {
    enable = lib.mkEnableOption "Enable sops";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ./secrets/general.yaml;
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        generateKey = true;
      };
      secrets = {
        "users/quinno/password" = {
          neededForUsers = true;
        };
      };
    };
  };
}
