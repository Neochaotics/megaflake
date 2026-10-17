# OpenSSH client configuration.
#
# Ported from home-manager's `modules/programs/ssh.nix` (BSD-3-Clause, (c)
# Home Manager contributors), including `enableDefaultConfig`, the legacy
# `matchBlocks` submodule and the ssh-agent service.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ssh;
  sshLib = import ../lib/ssh.nix { inherit lib; };

  inherit (lib)
    concatStringsSep
    mkOption
    optional
    optionalString
    removeSuffix
    replaceStrings
    types
    ;

  # home-manager's default `Host *` block.

  matchBlockModule = types.submodule (
    { ... }: {
      options = {
        hostname = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "github.com";
          description = "The host name.";
        };

        header = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "Match host *.example.org";
          description = ''
            Block header, for example `Host *.example.org`.
            Defaults to `Host <name>`.
          '';
        };

        user = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "root";
          description = "The user name.";
        };

        port = mkOption {
          type = types.nullOr types.port;
          default = null;
          example = 2222;
          description = "The port number.";
        };

        identityFile = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
          example = [
            "~/.ssh/id_rsa"
            "~/.ssh/id_ed25519"
          ];
          description = "The identity files.";
        };

        identitiesOnly = mkOption {
          type = types.nullOr types.bool;
          default = null;
          example = false;
          description = "Specifies that the user wants to use only the identity files.";
        };

        addKeysToAgent = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            When enabled, a private key that is used during authentication will
            be added to ssh-agent if it is running.
          '';
        };

        hashKnownHosts = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = ''
            Indicates that {command}`ssh` should hash host names and addresses
            when they are added to the known hosts file.
          '';
        };

        userKnownHostsFile = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Specifies one or more files to use for the user host key database.
          '';
        };

        controlMaster = mkOption {
          default = null;
          type = types.nullOr (
            types.enum [
              "yes"
              "no"
              "ask"
              "auto"
              "autoask"
            ]
          );
          description = "Configure sharing of multiple sessions over a single network connection.";
        };

        controlPath = mkOption {
          default = null;
          type = types.nullOr types.str;
          example = "~/.ssh/master-%r@%n:%p";
          description = ''
            Specify the path to the control socket used for connection sharing.
          '';
        };

        controlPersist = mkOption {
          default = null;
          type = types.nullOr types.str;
          example = "10m";
          description = ''
            Whether the control socket should remain open in the background
            after the initial connection closes.
          '';
        };

        forwardAgent = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = ''
            Enables the remote forwarding of the authentication agent.
          '';
        };

        compression = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = ''
            Enables compression. This is useful on slow links.
          '';
        };

        serverAliveInterval = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = ''
            Sets the timeout interval in seconds, after which, if no data has
            been received, ssh will send a message through the encrypted channel
            to request a reply from the server.
          '';
        };

        serverAliveCountMax = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = ''
            Sets the number of server alive messages sent by ssh that may be sent
            without ssh receiving any messages back from the server.
          '';
        };

        extraOptions = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = ''
            Extra `ssh_config` options for this host. Not supported by
            {command}`ssh`, will only be added to the ssh config.
          '';
        };
      };
    }
  );
in
{
  options.programs.ssh = {
    enable = lib.mkEnableOption "OpenSSH client";

    package = lib.mkPackageOption pkgs "openssh" { };

    enableDefaultConfig = lib.mkEnableOption "the default OpenSSH configuration" // {
      default = false;
    };

    settings = mkOption {
      type = types.attrsOf (types.attrsOf types.unspecified);
      default = { };
      example = lib.literalExpression ''
        {
          "github.com" = {
            User = "git";
            IdentityFile = "~/.ssh/github";
          };
        }
      '';
      description = ''
        OpenSSH client configuration blocks written to {file}`~/.ssh/config`.
      '';
    };

    matchBlocks = mkOption {
      type = types.attrsOf matchBlockModule;
      default = { };
      example = lib.literalExpression ''
        {
          "github.com" = {
            user = "git";
            hostname = "github.com";
            identityFile = "~/.ssh/github";
          };
        }
      '';
      description = ''
        Declarative specification of {command}`ssh` client configuration.
      '';
    };

    includes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "~/.config/ssh/config.d/*"
      ];
      description = ''
        File globs of ssh config files that should be included via
        {option}`programs.ssh.includes`.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra contents to add to the end of {file}`~/.ssh/config`.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableDefaultConfig {
      # home-manager's historical defaults for the catch-all host.
      warnings = [
        ''
          `programs.ssh.enableDefaultConfig` is deprecated: the defaults will
          be removed in a future release. Set the values you want to keep in
          `programs.ssh.settings."*"` instead.
        ''
      ];

      programs.ssh.settings."*" = {
        ForwardAgent = lib.mkDefault false;
        AddKeysToAgent = lib.mkDefault "no";
        Compression = lib.mkDefault false;
        ServerAliveInterval = lib.mkDefault 0;
        ServerAliveCountMax = lib.mkDefault 3;
        HashKnownHosts = lib.mkDefault false;
        UserKnownHostsFile = lib.mkDefault "~/.ssh/known_hosts";
        ControlMaster = lib.mkDefault "no";
        ControlPath = lib.mkDefault "~/.ssh/master-%r@%n:%p";
        ControlPersist = lib.mkDefault "no";
      };
    })

    (lib.mkIf cfg.enable (
      lib.mkMerge [
        {
          files.".ssh/config".text =
            let
              # Legacy `matchBlocks` are folded into `settings`, the way
              # home-manager's deprecation shim did, so only one code path
              # renders the file.
              legacyBlocks = lib.mapAttrs' (
                name: entry: lib.nameValuePair name (sshLib.legacyBlockSettings entry)
              ) cfg.matchBlocks;

              settings = lib.foldl' (
                acc: name:
                acc
                // {
                  "${name}" =
                    if acc ? "${name}" then acc."${name}" // legacyBlocks."${name}" else legacyBlocks."${name}";
                }
              ) cfg.settings (lib.attrNames legacyBlocks);

              defaultHostBlock = (settings."*" or null);

              globalConfig = lib.optional (cfg.includes != [ ]) "Include ${concatStringsSep " " cfg.includes}";
              blockConfig =
                (map (name: sshLib.matchBlockStr name settings.${name}) (
                  lib.filter (name: name != "*") (lib.attrNames settings)
                ))
                ++ optional (defaultHostBlock != null) (sshLib.matchBlockStr "*" defaultHostBlock);
              extraConfig = optional (cfg.extraConfig != "") (
                "  " + replaceStrings [ "\n" ] [ "\n  " ] (removeSuffix "\n" cfg.extraConfig)
              );
              sections =
                optional (globalConfig != [ ]) (concatStringsSep "\n" globalConfig) ++ blockConfig ++ extraConfig;
            in
            optionalString (sections != [ ]) (concatStringsSep "\n\n" sections + "\n");
        }
      ]
    ))
  ];
}
