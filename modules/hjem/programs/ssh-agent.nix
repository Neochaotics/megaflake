# OpenSSH agent and SSH_AUTH_SOCK propagation.
#
# Ported from home-manager's `modules/services/ssh-agent.nix` and
# `modules/misc/ssh-auth-sock.nix` (BSD-3-Clause, (c) Home Manager contributors),
# including the shell snippets injected into bash/zsh startup files.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sshAgent;

  socketPath = "$XDG_RUNTIME_DIR/${cfg.socket}";

  # Preserve $SSH_AUTH_SOCK if it stems from a forwarded agent, i.e. when both
  # $SSH_AUTH_SOCK and $SSH_CONNECTION are set.
  indentNonEmptyLines =
    str:
    lib.concatStringsSep "\n" (
      map (line: if line == "" then "" else "  ${line}") (lib.splitString "\n" str)
    );

  mkShIntegration = code: ''
    if [ -z "$SSH_AUTH_SOCK" -o -z "$SSH_CONNECTION" ]; then
    ${indentNonEmptyLines code}
    fi
  '';

  bashIntegration = mkShIntegration ''export SSH_AUTH_SOCK="${socketPath}"'';
  zshIntegration = mkShIntegration ''export SSH_AUTH_SOCK="${socketPath}"'';
in
{
  options.services.sshAgent = {
    enable = lib.mkEnableOption "OpenSSH private key agent";

    package = lib.mkPackageOption pkgs "openssh" { };

    socket = lib.mkOption {
      type = lib.types.str;
      default = "ssh-agent";
      example = "ssh-agent/socket";
      description = ''
        The agent's socket; interpreted as a suffix to {env}`$XDG_RUNTIME_DIR`.
      '';
    };

    defaultMaximumIdentityLifetime = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      example = 3600;
      description = ''
        Set a default value for the maximum lifetime in seconds of identities
        added to the agent.
      '';
    };

    pkcs11Whitelist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Specify a list of approved path patterns for PKCS#11 and FIDO
        authenticator middleware libraries.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # home-manager did not link openssh into the user profile; the binary is
    # referenced from the unit instead.

    # $SSH_AUTH_SOCK has to be set early since other tools rely on it.
    programs.bash.profileExtra = bashIntegration;
    programs.zsh.envExtra = ''
      if [[ ! -o login ]]; then
      ${indentNonEmptyLines zshIntegration}
      fi
    '';
    programs.zsh.profileExtra = zshIntegration;

    systemd.services = {
      ssh-agent = {
        wantedBy = [ "default.target" ];
        description = "SSH authentication agent";
        documentation = [ "man:ssh-agent(1)" ];
        serviceConfig = {
          ExecStart = "${lib.getExe' cfg.package "ssh-agent"} -D -a %t/${cfg.socket}${
            lib.optionalString (
              cfg.defaultMaximumIdentityLifetime != null
            ) " -t ${toString cfg.defaultMaximumIdentityLifetime}"
          }${
            lib.optionalString (
              cfg.pkcs11Whitelist != [ ]
            ) " -P '${lib.concatStringsSep "," cfg.pkcs11Whitelist}'"
          }";
          SuccessExitStatus = 2;
        };
      };

      set-SSH_AUTH_SOCK = {
        description = "Sets SSH_AUTH_SOCK in the D-BUS daemon and systemd";
        # Socket units are ordered before sockets.target by systemd. Ordering
        # this service before them creates a cycle through basic.target.
        before = [ "ssh-agent.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "set-SSH_AUTH_SOCK" ''
            ${bashIntegration}
            ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd SSH_AUTH_SOCK
          '';
        };
        wantedBy = [
          "default.target"
          "ssh-agent.service"
        ];
      };

    };
  };
}
