# Pointer cursor configuration.
#
# Ported from home-manager's `modules/config/home-cursor.nix` (BSD-3-Clause,
# (c) Home Manager contributors).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.pointerCursor;

  defaultIndexThemePackage = pkgs.writeTextFile {
    name = "index.theme";
    destination = "/share/icons/default/index.theme";
    # Set name in icons theme, for compatibility with AwesomeWM etc.
    text = ''
      [Icon Theme]
      Name=Default
      Comment=Default Cursor Theme
      Inherits=${cfg.name}
    '';
  };
in
{
  options.home.pointerCursor = {
    enable = lib.mkEnableOption "cursor config generation";

    package = lib.mkOption {
      type = lib.types.package;
      example = lib.literalExpression "pkgs.vanilla-dmz";
      description = "Package providing the cursor theme.";
    };

    name = lib.mkOption {
      type = lib.types.str;
      example = "Vanilla-DMZ";
      description = "The cursor name within the package.";
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = 32;
      example = 64;
      description = "The cursor size.";
    };

    dotIcons = {
      enable = lib.mkEnableOption "`.icons` config generation for pointerCursor" // {
        default = true;
      };
    };

    hyprcursor = {
      enable = lib.mkEnableOption "hyprcursor config generation";

      size = lib.mkOption {
        type = lib.types.int;
        default = cfg.size;
        defaultText = lib.literalExpression "config.home.pointerCursor.size";
        description = "The cursor size for hyprcursor.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        packages = [
          cfg.package
          defaultIndexThemePackage
        ];

        system.session.variables = {
          XCURSOR_SIZE = cfg.size;
          XCURSOR_THEME = cfg.name;
        };

        # Set directory to look for cursors in, needed for some applications
        # that are unable to find cursors otherwise.
        system.session.searchVariables.XCURSOR_PATH = [
          "${config.home.profileDirectory}/share/icons"
        ];

        # Add cursor icon link to $XDG_DATA_HOME/icons as well for redundancy.
        xdg.data.files."icons/default/index.theme".source =
          "${defaultIndexThemePackage}/share/icons/default/index.theme";
        xdg.data.files."icons/${cfg.name}".source = "${cfg.package}/share/icons/${cfg.name}";
      }

      (lib.mkIf cfg.hyprcursor.enable {
        system.session.variables = {
          HYPRCURSOR_THEME = cfg.name;
          HYPRCURSOR_SIZE = cfg.hyprcursor.size;
        };
      })

      (lib.mkIf cfg.dotIcons.enable {
        files.".icons/default/index.theme".source =
          "${defaultIndexThemePackage}/share/icons/default/index.theme";
        files.".icons/${cfg.name}".source = "${cfg.package}/share/icons/${cfg.name}";
      })
    ]
  );
}
