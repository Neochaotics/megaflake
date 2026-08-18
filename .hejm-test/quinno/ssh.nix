_: {
  flake.modules.nixos.quinno-ssh =
    { config, ... }:
    let
      home = config.users.users.quinno.home;
    in
    {
      hjem.users.quinno.programs.ssh = {
        enable = true;
        matchBlocks = {
          github = {
            hostname = "github.com";
            identityFile = [ "${home}/.ssh/ssh_id_ed25519_key" ];
          };
          "gitlab.com" = {
            hostname = "gitlab.com";
            identityFile = [ "${home}/.ssh/id_isc_gitlab" ];
          };
          "codeberg.org" = {
            hostname = "codeberg.org";
            identityFile = [ "${home}/.ssh/id_codeberg" ];
          };
          "capuchin-us-ne" = {
            hostname = "5.161.179.69";
            identityFile = [ "${home}/.ssh/id_codeberg" ];
          };
          "kogatana" = {
            hostname = "kogatana";
            identityFile = [ "${home}/.ssh/id_codeberg" ];
          };
        };
      };
    };
}
