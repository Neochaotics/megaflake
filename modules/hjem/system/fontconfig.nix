# fontconfig configuration.
#
# Ported from home-manager's `modules/misc/fontconfig.nix` (BSD-3-Clause, (c)
# Home Manager contributors). Reproduces `10-hm-fonts.conf` and
# `52-hm-default-fonts.conf` byte-for-byte, including the reference to the
# user profile store path.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fonts.fontconfig;
  xml = pkgs.formats.xml { };

  inherit (lib) mkOption optional optionals;

  mkInclude = path: {
    "@ignore_missing" = "yes";
    "#text" = path;
  };

  fontConfigFileType = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "this fontconfig file";

        label = mkOption {
          description = "Label to use for the name of the config file.";
          default = name;
          defaultText = lib.literalExpression "<name>";
          type = lib.types.str;
        };

        priority = mkOption {
          description = ''
            Determines the order in which configuration files are loaded.

            Must be a value within the range of 0-99, where priority 0 is
            the highest priority and 99 is the lowest.
          '';
          default = 90;
          type = lib.types.ints.between 0 99;
        };

        settings = mkOption {
          inherit (xml) type;
          default = { };
          example = {
            description = "Enable antialiasing";
            match = {
              "@target" = "font";
              edit = {
                "@mode" = "assign";
                "@name" = "antialias";
                bool = "true";
              };
            };
          };
          description = ''
            Structured attrs of settings in the format of `pkgs.formats.xml {}`.
            The settings are implicitly wrapped inside the `<fontconfig>` tag,
            i.e. as `{ fontconfig = <settings>; }`.
          '';
        };

        source = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          readOnly = true;
          description = "Path to the rendered config file.";
        };
      };
    }
  );
in
{
  options.fonts = {
    fontconfig = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable fontconfig configuration.";
      };

      # Home Manager exposes this as an internal option; the font include file
      # embeds it, so hjem needs the same store path.
      homePath = mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Store path of the environment built from the user profile packages.

          Rendered into {file}`10-hm-fonts.conf`.
        '';
      };

      profileDirectory = mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Profile directory rendered into {file}`10-hm-fonts.conf`.";
      };

      defaultFonts = {
        monospace = mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Per-user default monospace font(s).";
        };

        sansSerif = mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Per-user default sans serif font(s).";
        };

        serif = mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Per-user default serif font(s).";
        };

        emoji = mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Per-user default emoji font(s).";
        };
      };

      antialiasing = lib.mkOption {
        type = with lib.types; nullOr bool;
        default = null;
        description = "Whether to enable font antialiasing.";
      };

      hinting = lib.mkOption {
        type =
          with lib.types;
          nullOr (enum [
            "none"
            "slight"
            "medium"
            "full"
          ]);
        default = null;
        description = "The font hinting mode.";
      };

      subpixelRendering = lib.mkOption {
        type =
          with lib.types;
          nullOr (enum [
            "none"
            "rgb"
            "bgr"
            "vertical-rgb"
            "vertical-bgr"
          ]);
        default = null;
        description = "The sub-pixel rendering mode.";
      };

      configFile = lib.mkOption {
        type = lib.types.attrsOf fontConfigFileType;
        default = { };
        description = ''
          Config files that will be installed to
          {file}`$XDG_CONFIG_HOME/fontconfig/conf.d/`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      # Make sure that buildEnv creates a real directory path so that we avoid
      # trying to write to a read-only location.
      (pkgs.runCommandLocal "dummy-fc-dir1" { } "mkdir -p $out/lib/fontconfig")
      (pkgs.runCommandLocal "dummy-fc-dir2" { } "mkdir -p $out/lib/fontconfig")
    ];

    fonts.fontconfig.configFile = {
      fonts = {
        enable = true;
        priority = 10;
        settings = {
          description = "Add fonts in the Nix user profile";
          include = map mkInclude [
            "${cfg.homePath}/etc/fonts/conf.d"
            "${cfg.homePath}/etc/fonts/fonts.conf"
          ];
          dir = [
            "${cfg.homePath}/lib/X11/fonts"
            "${cfg.homePath}/share/fonts"
            "${cfg.profileDirectory}/lib/X11/fonts"
            "${cfg.profileDirectory}/share/fonts"
          ];
          cachedir = "${cfg.homePath}/lib/fontconfig/cache";
        };
      };

      rendering =
        let
          toXmlValue =
            value:
            if lib.isBool value then
              { bool = lib.boolToString value; }
            else if lib.isString value then
              { const = value; }
            else
              throw "expected bool or string but got ${lib.typeOf value}: ${toString value}";
          assign =
            name: value:
            toXmlValue value
            // {
              "@mode" = "assign";
              "@name" = name;
            };
          content =
            optional (cfg.antialiasing != null) (assign "antialias" cfg.antialiasing)
            ++ optionals (cfg.hinting != null) [
              (assign "hinting" true)
              (assign "hintstyle" ("hint" + cfg.hinting))
            ]
            ++ optional (cfg.subpixelRendering != null) (
              assign "rgba" (lib.replaceStrings [ "ertical-" ] [ "" ] cfg.subpixelRendering)
            );
        in
        {
          enable = lib.length content > 0;
          priority = 10;
          settings = {
            description = "Set the rendering mode";
            match = {
              "@target" = "font";
              edit = content;
            };
          };
        };

      default-fonts =
        let
          filterNonEmpty = lib.filterAttrs (_: fonts: fonts != [ ]);
          mkAlias = name: fonts: {
            "@binding" = "same";
            family = if name == "sansSerif" then "sans-serif" else name;
            prefer.family = fonts;
          };
        in
        {
          enable = true;
          priority = 52;
          settings = {
            description = "Set default fonts";
            alias = lib.mapAttrsToList mkAlias (filterNonEmpty cfg.defaultFonts);
          };
        };
    };

    xdg.config.files = lib.mapAttrs' (
      _name: file:
      lib.nameValuePair "fontconfig/conf.d/${toString file.priority}-hm-${file.label}.conf" {
        inherit (file) enable;
        source =
          if file.settings == { } then
            null
          else
            xml.generate "hm-fontconfig-${file.label}.xml" { fontconfig = file.settings; };
      }
    ) cfg.configFile;
  };
}
