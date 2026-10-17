# Shared user-home options that Home Manager used to provide.
#
# Hjem does not model a Nix profile, so anything that used to reference
# `home.profileDirectory` (or the per-user profile store path) needs its own
# option. These are set once by the host and consumed by the modules that
# previously embedded Home Manager's values.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home;
in
{
  options.home = {
    profileDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/etc/profiles/per-user/${config.user}";
      defaultText = lib.literalExpression ''"/etc/profiles/per-user/${config.user}"'';
      readOnly = true;
      description = ''
        The profile directory where the user profile packages are installed.

        With NixOS' per-user profiles this is
        {file}`/etc/profiles/per-user/<username>`.
      '';
    };

    # Home Manager builds this with `pkgs.buildEnv { name = "home-manager-path"; }`
    # over its package list, and the fontconfig include file embeds the result.
    # Recreating it keeps that file byte-identical.
    profilePath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Store path of the profile environment, when it needs to be referenced
        from a generated config file.
      '';
    };
  };

  config = {
    home.profilePath = lib.mkDefault (
      pkgs.buildEnv {
        name = "home-manager-path";
        paths = config.packages;
      }
    );

    fonts.fontconfig = {
      homePath = cfg.profilePath;
      profileDirectory = cfg.profileDirectory;
    };
  };
}
