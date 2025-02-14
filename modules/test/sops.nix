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

  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.cm.nixos.system.sops = {
    enable = lib.mkEnableOption "Enable sops";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = /etc/nixos/modules/system/secrets/general.yaml;
      age = {
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
