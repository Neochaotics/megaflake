# Firefox configuration.
#
# Ported from home-manager's `modules/programs/firefox/*` (BSD-3-Clause, (c)
# Home Manager contributors). Covers what this host uses: `profiles.ini`, the
# profile directory, the extension directory, `search.json.mozlz4`, native
# messaging hosts, and enterprise policies via the package wrapper.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.firefox;

  # The extensions path shared by all profiles.
  extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

  profiles =
    lib.flip lib.mapAttrs' cfg.profiles (
      _: profile:
      lib.nameValuePair "Profile${toString profile.id}" (
        {
          Name = profile.name;
          Path = profile.path;
          IsRelative = 1;
          Default = if profile.isDefault then 1 else 0;
        }
        // lib.optionalAttrs (profile.storeId != null) {
          StoreID = profile.storeId;
        }
      )
    )
    // {
      General = {
        StartWithLastProfile = 1;
      }
      // lib.optionalAttrs (cfg.profileVersion != null) {
        Version = cfg.profileVersion;
      };
    };

  profilesIni = lib.generators.toINI { } profiles;

  extensionsEnvPkg = pkgs.buildEnv {
    name = "hm-firefox-extensions";
    paths = cfg.extensions.packages;
  };

  defaultNmhPaths = [
    # Link a .keep file to keep the directory around
    (pkgs.writeTextDir "lib/mozilla/native-messaging-hosts/.keep" "")
  ];

  nmhPackage = pkgs.symlinkJoin {
    name = "mozilla-native-messaging-hosts";
    paths = defaultNmhPaths;
  };
in
{
  options.programs.firefox = {
    enable = lib.mkEnableOption "Mozilla Firefox";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firefox;
      defaultText = lib.literalExpression "pkgs.firefox";
      description = ''
        The Firefox package to install.

        Enterprise policies are passed to the package wrapper through
        {option}`programs.firefox.policies`, exactly like home-manager did.
      '';
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      default = ".mozilla/firefox";
      defaultText = lib.literalExpression ''".mozilla/firefox"'';
      description = ''
        Path to the Firefox configuration directory, relative to
        {file}`$HOME` unless absolute.
      '';
    };

    profileVersion = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "2";
      defaultText = lib.literalExpression ''"2"'';
      description = ''
        Version of {file}`profiles.ini`. Set to `null` to omit the `Version`
        key.
      '';
    };

    policies = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      example = {
        DefaultDownloadDirectory = "~/Downloads";
        BlockAboutConfig = true;
      };
      description = ''
        [See the list of policies](https://mozilla.github.io/policy-templates/).

        They are baked into the browser package, which is how home-manager
        applied them on Linux.
      '';
    };

    extensions = {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        example = lib.literalExpression "[ pkgs.ublock-origin ]";
        description = ''
          Add-on packages to install into the profile's `extensions`
          directory.
        '';
      };

      force = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          When enabled, the `extensions` directory is replaced instead of
          merged.
        '';
      };
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }: {
            options = {
              id = lib.mkOption {
                type = lib.types.int;
                default = 0;
                example = 0;
                description = "Index of the profile, used for the `Profile<N>` section.";
              };

              name = lib.mkOption {
                type = lib.types.str;
                default = name;
                defaultText = lib.literalExpression "<name>";
                example = "default";
                description = "Name of the profile.";
              };

              path = lib.mkOption {
                type = lib.types.str;
                default = name;
                defaultText = lib.literalExpression "<name>";
                example = "default";
                description = ''
                  Path to the profile directory, relative to the
                  {file}`$XDG_CONFIG_HOME/${cfg.configPath}`.
                '';
              };

              isDefault = lib.mkOption {
                type = lib.types.bool;
                default = false;
                example = true;
                description = "Whether this is the default profile.";
              };

              storeId = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  When set, {file}`profiles.ini` is created with a predictable
                  `StoreID`.
                '';
              };
            };
          }
        )
      );
      default = { };
      description = ''
        Declarative Firefox profile definitions.

        This host only needs a single `default` profile; the search engine
        settings and extension packages are declared at
        {option}`programs.firefox.search` and
        {option}`programs.firefox.extensions`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # home-manager passed `extraPolicies` to the package wrapper.
    packages = [
      (
        if cfg.policies == { } then
          cfg.package
        else
          cfg.package.override (old: {
            extraPolicies = (old.extraPolicies or { }) // cfg.policies;
          })
      )
    ];

    files."${cfg.configPath}/profiles.ini" = lib.mkIf (cfg.profiles != { }) { text = profilesIni; };

    files."${cfg.configPath}/${cfg.profiles.default.path}/.keep".text = "";

    files."${cfg.configPath}/${cfg.profiles.default.path}/extensions" =
      lib.mkIf (cfg.extensions.packages != [ ])
        {
          source = "${extensionsEnvPkg}/share/mozilla/${extensionPath}";
        };

    files.".mozilla/native-messaging-hosts".source = "${nmhPackage}/lib/mozilla/native-messaging-hosts";
  };
}
