# XDG base directories, user directories and MIME associations.
#
# Ported from home-manager's `modules/misc/xdg/{default,user-dirs,mime-apps}.nix`
# (BSD-3-Clause, (c) Home Manager contributors).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.xdg;
  userDirs = cfg.userDirs;

  userDirsBindings = lib.mapAttrs' (k: v: lib.nameValuePair "XDG_${k}_DIR" v) (
    lib.filterAttrs (_n: v: !isNull v) {
      DESKTOP = userDirs.desktop;
      DOCUMENTS = userDirs.documents;
      DOWNLOAD = userDirs.download;
      MUSIC = userDirs.music;
      PICTURES = userDirs.pictures;
      PROJECTS = userDirs.projects;
      PUBLICSHARE = userDirs.publicShare;
      TEMPLATES = userDirs.templates;
      VIDEOS = userDirs.videos;
    }
    // userDirs.extraConfig
  );

  joinValues = lib.mapAttrs (_n: lib.concatStringsSep ";");

  mimeappsList = (pkgs.formats.ini { }).generate "mimeapps.list" {
    "Added Associations" = joinValues cfg.mimeApps.associations.added;
    "Removed Associations" = joinValues cfg.mimeApps.associations.removed;
    "Default Applications" = joinValues cfg.mimeApps.defaultApplications;
  };
in
{
  options.xdg = {
    enable = lib.mkEnableOption "XDG base directory specification support";

    userDirs = {
      enable = lib.mkEnableOption "management of $XDG_CONFIG_HOME/user-dirs.dirs";

      package = lib.mkPackageOption pkgs "xdg-user-dirs" { nullable = true; };

      desktop = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Desktop";
        description = "The Desktop directory.";
      };

      documents = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Documents";
        description = "The Documents directory.";
      };

      download = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Downloads";
        description = "The Downloads directory.";
      };

      music = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Music";
        description = "The Music directory.";
      };

      pictures = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Pictures";
        description = "The Pictures directory.";
      };

      projects = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Projects";
        description = "The Projects directory.";
      };

      publicShare = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Public";
        description = "The Public share directory.";
      };

      templates = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Templates";
        description = "The Templates directory.";
      };

      videos = lib.mkOption {
        type = with lib.types; nullOr (lib.types.coercedTo lib.types.path toString str);
        default = "${config.directory}/Videos";
        description = "The Videos directory.";
      };

      extraConfig = lib.mkOption {
        type = lib.types.attrsOf (with lib.types; coercedTo path toString str);
        default = { };
        example = {
          MISC = "${config.directory}/Misc";
        };
        description = ''
          Other user directories. The key `MISC` corresponds to the user-dirs
          entry `XDG_MISC_DIR`.
        '';
      };

      createDirectories = lib.mkEnableOption "automatic creation of the XDG user directories";

      setSessionVariables = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to set the XDG user dir environment variables, like
          `XDG_DESKTOP_DIR`.
        '';
      };
    };

    mimeApps = {
      enable = lib.mkEnableOption "management of $XDG_CONFIG_HOME/mimeapps.list";

      associations = {
        added = lib.mkOption {
          type = lib.types.attrsOf (lib.types.listOf lib.types.str);
          default = { };
          example = {
            "text/plain" = [ "nano.desktop" ];
          };
          description = "Associations added by this configuration.";
        };

        removed = lib.mkOption {
          type = lib.types.attrsOf (lib.types.listOf lib.types.str);
          default = { };
          example = {
            "application/x-mimearchive" = [ "totem.desktop" ];
          };
          description = "Associations removed by this configuration.";
        };
      };

      defaultApplications = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
        example = {
          "text/plain" = [ "nano.desktop" ];
        };
        description = "Default application for the given mimetypes.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # home-manager configured the cache directory as `~/.local/cache`.
      xdg.cache.directory = "${config.directory}/.local/cache";

      # Empty directory keepers, as Home Manager generated.
      xdg.cache.files.".keep".text = "";
      xdg.state.files.".keep".text = "";

      system.session = {
        variables = {
          XDG_BIN_HOME = "${config.directory}/.local/bin";
          XDG_CACHE_HOME = cfg.cache.directory;
          XDG_CONFIG_HOME = cfg.config.directory;
          XDG_DATA_HOME = cfg.data.directory;
          XDG_STATE_HOME = cfg.state.directory;
        };

        # home-manager only wrote the base directories to the systemd
        # environment, so keep the rest out of it.
        systemdVariables = {
          XDG_BIN_HOME = "${config.directory}/.local/bin";
          XDG_CACHE_HOME = cfg.cache.directory;
          XDG_CONFIG_HOME = cfg.config.directory;
          XDG_DATA_HOME = cfg.data.directory;
          XDG_STATE_HOME = cfg.state.directory;
        };
      };
    })

    (lib.mkIf userDirs.enable {
      xdg.config.files."user-dirs.dirs".text =
        let
          # For some reason, these need to be wrapped with quotes to be valid.
          wrapped = lib.mapAttrs (_: value: ''"${value}"'') userDirsBindings;
        in
        lib.generators.toKeyValue { } wrapped;

      xdg.config.files."user-dirs.conf".text = "enabled=False";

      packages = lib.mkIf (userDirs.package != null) [ userDirs.package ];

      system.session = lib.mkIf userDirs.setSessionVariables {
        variables = userDirsBindings;
      };
    })

    (lib.mkIf cfg.mimeApps.enable {
      xdg.config.files."mimeapps.list".source = mimeappsList;

      # Deprecated but still used by some applications.
      xdg.data.files."applications/mimeapps.list".source = mimeappsList;

      packages = [
        # Explicitly install a package to provide basic mime types.
        pkgs.shared-mime-info

        # Make sure the target directories will be real directories.
        (pkgs.runCommandLocal "dummy-xdg-mime-dirs1" { } ''
          mkdir -p $out/share/{applications,mime/packages}
        '')
        (pkgs.runCommandLocal "dummy-xdg-mime-dirs2" { } ''
          mkdir -p $out/share/{applications,mime/packages}
        '')
      ];
    })
  ];
}
