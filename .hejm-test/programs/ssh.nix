{ pkgs, ... }:
let
  sshConfig = { name, block }: ''
    Host ${name}
      Hostname ${block.hostname}
      IdentityFile ${builtins.head block.identityFile}
      IdentitiesOnly ${if block.identitiesOnly then "yes" else "no"}
      AddKeysToAgent ${block.addKeysToAgent}
  '';
in
{
  flake.modules.nixos.ssh = {
    services.openssh.enable = true;
  };

  flake.modules.hjem.ssh =
    { config, lib, ... }:
    let
      cfg = config.programs.ssh;
    in
    {
      options.programs.ssh = {
        enable = lib.mkEnableOption "SSH client configuration";
        matchBlocks = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                hostname = lib.mkOption { type = lib.types.str; };
                identityFile = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                };
                identitiesOnly = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                };
                addKeysToAgent = lib.mkOption {
                  type = lib.types.str;
                  default = "yes";
                };
              };
            }
          );
          default = { };
        };
      };

      config = lib.mkIf cfg.enable {
        packages = [ pkgs.openssh ];

        files.".ssh/config".text = lib.mkIf (cfg.matchBlocks != { }) (
          lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: block: sshConfig { inherit name block; }) cfg.matchBlocks
          )
        );
      };
    };
}
