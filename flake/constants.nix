{
  flake.modules.nixos.constants =
    { config, lib, ... }:
    let
      constants = {
        options.constants = {
          username = lib.mkOption {
            type = lib.types.str;
            default = "quinno";
            description = "The primary interactive user on this host.";
          };

          home = lib.mkOption {
            type = lib.types.str;
            default = "/home/${config.constants.username}";
            description = "Home directory for the primary interactive user.";
          };

          stateVersion = lib.mkOption {
            type = lib.types.str;
            default = "24.11";
            description = "NixOS state version for this host.";
          };
        };
      };
    in
    {
      imports = [ constants ];

      system.stateVersion = config.constants.stateVersion;
    };
}
