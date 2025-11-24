{
  lib,
  config,
  self,
  ...
}:
let
  cfg = config.qm.programs.ssh;

  pathtokeys = "${self}" + "/secrets/keys";
  yubikeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathtokeys))
      # Remove the .pub suffix
      (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key);
  yubikeyPublicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map
      # list of dicts
      (key: { ".ssh/${key}.pub".source = "${pathtokeys}/${key}.pub"; })
      yubikeys
  );

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
    home.file = {
      ".ssh/sockets/.keep".text = "# Managed by Home Manager";
    }
    // yubikeyPublicKeyEntries;
  };
}
