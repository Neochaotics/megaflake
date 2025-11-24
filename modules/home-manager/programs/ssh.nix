{
  lib,
  config,
  self,
  ...
}:
let
  cfg = config.qm.programs.ssh;
in
{
  options.qm.programs.ssh = {
    enable = lib.mkEnableOption "Enable ssh configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      matchBlocks = {
        github = {
          hostname = "github.com";
          identityFile = [ "${config.home.homeDirectory}/.ssh/ssh_id_ed25519_key" ];
          identitiesOnly = true;
        };
      };
    };
  };
}
