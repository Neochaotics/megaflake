# Firefox search engine configuration.
#
# Ported from home-manager's `modules/programs/firefox/profiles/search.nix`
# (BSD-3-Clause, (c) Home Manager contributors): the same v12 `search.json`
# document, the same salting and the same mozlz4 compression, so the
# generated `search.json.mozlz4` is byte-identical.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.firefox.search;

  appName = "Firefox";

  # Map of nice field names to internal field names, exhaustive per version.
  internalFieldNames =
    (lib.genAttrs [
      "name"
      "isAppProvided"
      "loadPath"
      "updateInterval"
      "updateURL"
      "iconMapObj"
      "metaData"
      "orderHint"
      "definedAliases"
      "urls"
    ] (name: "_${name}"))
    // {
      searchForm = "__searchForm";
    };

  iconUrl = icon: if lib.isPath icon || lib.hasPrefix "/" icon then "file://${icon}" else icon;

  processCustomEngineInput =
    input:
    {
      name = input.id;
    }
    // (lib.removeAttrs input [ "icon" ])
    // lib.optionalAttrs (input ? icon || input ? iconMapObj) {
      iconMapObj = lib.mapAttrs (_name: iconUrl) (
        (lib.optionalAttrs (input ? icon) {
          # Convenience to specify a single icon instead of a map.
          "16" = input.icon;
        })
        // (input.iconMapObj or { })
      );
    }
    // {
      # Required for custom engine configurations; loadPaths are unique
      # identifiers, generally formatted like "[source]/path/to/engine.xml".
      loadPath = "[home-manager]/programs.firefox.profiles.${cfg.profileName}.search.engines.${input.id}";
    };

  migrateEngineToV11 = engine: engine;

  migrateEngineToV12 =
    engine:
    let
      iconMapObj =
        lib.optionalAttrs (engine ? iconURL) { "16" = engine.iconURL; }
        // lib.optionalAttrs (engine ? iconUpdateURL) { "16" = engine.iconUpdateURL; }
        // (engine.iconMapObj or { });
    in
    (lib.removeAttrs engine [
      "iconURL"
      "iconUpdateURL"
    ])
    // lib.optionalAttrs (iconMapObj != { }) { inherit iconMapObj; };

  processEngineInput =
    id: input:
    let
      requiredInput = {
        inherit id;
        isAppProvided = input.isAppProvided or (lib.removeAttrs input [ "metaData" ] == { });
        metaData = input.metaData or { };
      };
    in
    if requiredInput.isAppProvided then
      requiredInput
    else
      lib.foldl' (acc: f: f acc) input [
        (x: x // requiredInput)
        migrateEngineToV11
        migrateEngineToV12
        processCustomEngineInput
      ];

  buildEngineConfig =
    name: input:
    lib.mapAttrs' (name: value: {
      name = internalFieldNames.${name} or name;
      inherit value;
    }) (processEngineInput name input);

  sortEngineConfigs =
    configs:
    let
      buildEngineConfigWithOrder =
        order: id:
        let
          config_ =
            configs.${id} or {
              inherit id;
              _isAppProvided = true;
              _metaData = { };
            };
        in
        config_
        // {
          _metaData = config_._metaData // {
            inherit order;
          };
        };

      engineConfigsWithoutOrder = lib.attrValues (lib.removeAttrs configs cfg.order);

      sortedEngineConfigs = (lib.imap1 buildEngineConfigWithOrder cfg.order) ++ engineConfigsWithoutOrder;
    in
    sortedEngineConfigs;

  engineInput =
    cfg.engines
    // {
      # Infer the default as an app-provided engine if it is not declared.
      ${cfg.default} = cfg.engines.${cfg.default} or { };
    }
    // {
      ${cfg.privateDefault} = cfg.engines.${cfg.privateDefault} or { };
    };

  settings = {
    version = 12;
    engines = sortEngineConfigs (lib.mapAttrs buildEngineConfig engineInput);

    metaData =
      lib.optionalAttrs (cfg.default != null) {
        defaultEngineId = cfg.default;
        defaultEngineIdHash = "@hash@";
      }
      // lib.optionalAttrs (cfg.privateDefault != null) {
        privateDefaultEngineId = cfg.privateDefault;
        privateDefaultEngineIdHash = "@privateHash@";
      }
      // {
        useSavedOrder = cfg.order != [ ];
      };
  };

  # Home Manager doesn't circumvent user consent; this claim travels with the
  # salted engine hashes.
  disclaimer =
    "By modifying this file, I agree that I am doing so "
    + "only within @appName@ itself, using official, user-driven search "
    + "engine selection processes, and in a way which does not circumvent "
    + "user consent. I acknowledge that any attempt to change this file "
    + "from outside of @appName@ is a malicious act, and will be responded "
    + "to accordingly.";

  # Home Manager salts with the profile's path relative to the configuration
  # directory (for example `default`), not with an absolute path.
  profilePath = cfg.profileName;

  salt = if cfg.default != null then profilePath + cfg.default + disclaimer else null;
  privateSalt =
    if cfg.privateDefault != null then profilePath + cfg.privateDefault + disclaimer else null;

  file =
    pkgs.runCommand "search.json.mozlz4"
      {
        nativeBuildInputs = [
          pkgs.mozlz4a
          pkgs.openssl
        ];
        json = builtins.toJSON settings;
        inherit salt privateSalt;
      }
      ''
        appName=${lib.escapeShellArg appName}

        salt=''${salt//@appName@/"$appName"}
        privateSalt=''${privateSalt//@appName@/"$appName"}

        if [[ -n $salt ]]; then
          export hash=$(echo -n "$salt" | openssl dgst -sha256 -binary | base64)
          export privateHash=$(echo -n "$privateSalt" | openssl dgst -sha256 -binary | base64)
          mozlz4a <(substituteStream json search.json.in --subst-var hash --subst-var privateHash) "$out"
        else
          mozlz4a <(echo "$json") "$out"
        fi
      '';
in
{
  options.programs.firefox.search = {
    profileName = lib.mkOption {
      type = lib.types.str;
      default = "default";
      internal = true;
      description = "Name of the profile the search configuration belongs to.";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      default = config.programs.firefox.configPath;
      internal = true;
      description = "Path of the Firefox configuration directory.";
    };

    engines = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      example = lib.literalExpression ''
        {
          "DuckDuckGo" = {
            isAppProvided = true;
            metaData.hidden = true;
          };
        }
      '';
      description = ''
        Search engine configuration, keyed by engine id.

        Setting an attribute to `{ }` marks an app-provided engine.
      '';
    };

    default = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "DuckDuckGo";
      description = "The default search engine.";
    };

    privateDefault = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "DuckDuckGo";
      description = "The default search engine for private windows.";
    };

    order = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "Brave"
        "ddg"
      ];
      description = "The order of the search engines.";
    };
  };

  config = lib.mkIf (cfg != { }) {
    files."${config.programs.firefox.configPath}/${cfg.profileName}/search.json.mozlz4".source = file;
  };
}
