{
  lib,
  config,
  pkgs,
  inputs,
  self,
  pkgs-stable,
  ...
}:
let
  username = "quinno";
  formatUsername =
    name:
    lib.strings.stringAsChars (
      c:
      if c == builtins.substring ((builtins.stringLength name) - 1) 1 name then
        " ${lib.strings.toUpper c}"
      else if c == (builtins.substring 0 1 name) then
        lib.strings.toUpper c
      else
        c
    ) name;

  elementWebConfig = pkgs.writeText "element-config.json" (
    builtins.toJSON {
      brand = "Freedchat";
      default_server_name = "matrix.org";
      disable_guests = true;
      disable_3pid_login = true;
      disable_login_language_selector = true;
      show_labs_settings = true;
      force_verification = true;
      enable_presence_by_hs_url = {
        "https://matrix.org" = false;
        "https://matrix-client.matrix.org" = false;
      };
      integrations_ui_url = null;
      integrations_rest_url = null;
      integrations_widgets_urls = null;
      features = {
        feature_group_calls = true;
        feature_element_call_video_rooms = true;
        feature_video_rooms = true;
      };
      element_call = {
        use_exclusively = true;
        brand = "Freedpom Call";
      };
      jitsi = {
        preferred_domain = null;
      };
      setting_defaults = {
        "UIFeature.urlPreviews" = false;
        "UIFeature.shareQrCode" = false;
        "UIFeature.shareSocial" = false;
        "UIFeature.widgets" = false;
        "UIFeature.feedback" = false;
        "UIFeature.identityServer" = false;
        "UIFeature.thirdPartyId" = false;
        "UIFeature.advancedEncryption" = true;
        "UIFeature.advancedSettings" = true;
        "UIFeature.roomHistorySettings" = true;
        urlPreviewsEnabled = false;
        webRtcAllowPeerToPeer = false;
        enableEventIndexing = false;
        showAvatarChanges = false;
        showDisplaynameChanges = false;
        showJoinLeaves = false;
      };
    }
  );
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.fluxcast-flake.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.hjem.nixosModules.default
    inputs.preservation.nixosModules.default
    inputs.nix-mineral.nixosModules.nix-mineral
    self.nixosModules.ffDefault
    inputs.freedpom.modules.nixos.ntpd
    inputs.freedpom.modules.nixos.locale
    inputs.freedpom.modules.nixos.ananicy
    inputs.freedpom.modules.nixos.daemon
    inputs.freedpom.modules.nixos.performance
    inputs.freedpom.modules.nixos.steam
    ./disk-primary.nix
    ./disk-secondary.nix
    ./hardware.nix
    ./gpu.nix
  ];

  environment.systemPackages = with pkgs; [
    pavucontrol
    podman-compose
    prismlauncher
    r2modman
    vscodium
    netbird
    (element-desktop.override { commandLineArgs = "--config ${elementWebConfig}"; })
    me3
  ];

  age = {
    rekey = {
      agePlugins = [ pkgs.age-plugin-yubikey ];
      hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDX9AJIAYoQF1zAXtRkxhdJuxAkn00rfayPC1B0aoIXy root@titan";
      masterIdentities = [
        {
          # Shinju
          identity = "AGE-PLUGIN-YUBIKEY-1GDE3QQ5ZLTSN3QSS37XZ7";
          pubkey = "age1yubikey1qdvsf3r75px0rcdc035uyzk4wnul223dxkpcgsj4qt4pnsy6dcfv5wkxgyk";
        }
        {
          # Kagami
          identity = "AGE-PLUGIN-YUBIKEY-1DCRWKQVZK894T4GARVMJX";
          pubkey = "age1yubikey1qfrkl29gapd5n0fxvfwwws5dkvtteh36wm46dekl4srdpk3x3evvguzryz6";
        }
      ];
      localStorageDir = "${self}" + "/secrets/rekeyed/${config.networking.hostName}";
      generatedSecretsDir = "${self}" + "/secrets/generated/${config.networking.hostName}";
      storageMode = "local";
    };
    secrets = {
      "${username}-password" = {
        rekeyFile = "${self}" + "/secrets/users/${username}/pass.age";
      };
    };
  };

  # Hjem: declarative management of $HOME.
  hjem = {
    clobberByDefault = true;
    users.${username} = import ./hjem.nix;
    extraModules = [
      # Module collection (hyprland, foot, fuzzel, git, yazi, hyprlock, ...)
      inputs.hjem-rum.hjemModules.default
      # Local modules (bash, zsh, ssh, firefox, systemd user units, ...)
      self.hjemModules.default
      # Core config (opencode.json, tui.json, vibeguard, AGENTS.md, theme)
      inputs.freedpom.modules.hjem.opencode-core
      # Tooling (opencode binary, nixd, nixfmt, alejandra, statix, etc.)
      inputs.freedpom.modules.hjem.opencode-tooling
      # Skills, agents, commands
      inputs.freedpom.modules.hjem.opencode-skills
      inputs.freedpom.modules.hjem.opencode-agents
      inputs.freedpom.modules.hjem.opencode-commands
      # Plugins
      inputs.freedpom.modules.hjem.opencode-plugin-token-tracker
      inputs.freedpom.modules.hjem.opencode-plugin-subagent-reporter
      inputs.freedpom.modules.hjem.opencode-plugin-handoff
      inputs.freedpom.modules.hjem.opencode-plugin-opencode-ignore
      inputs.freedpom.modules.hjem.opencode-plugin-agent-memory
      inputs.freedpom.modules.hjem.opencode-plugin-log-sanitizer
      inputs.freedpom.modules.hjem.opencode-plugin-nix-safe
      inputs.freedpom.modules.hjem.opencode-plugin-shell-strategy
    ];
    # hjem modules cannot see flake inputs by default.
    specialArgs.inputs = inputs;
  };

  security.rtkit.enable = true;

  # Gamemode: boost games to nice -10 + desktop notification on start/stop.
  # steam.nix already enables the service; these are the tunables.
  programs.gamemode.settings = {
    general = {
      renice = 10;
      softrealtime = "auto";
    };
    custom = {
      start = "hyprctl notify 5 3000 0 'GameMode started'";
      end = "hyprctl notify 6 3000 0 'GameMode ended'";
    };
  };

  # Gamescope WSI: enables Vulkan WSI layer for native HDR games
  programs.gamescope.enableWsi = true;
  # Disable setcap wrapper — Steam's bwrap sandbox can't inherit capabilities
  # ("failed to inherit capabilities: Operation not permitted")
  programs.gamescope.capSysNice = lib.mkForce false;

  systemd = {
    user.services.wireplumber.wantedBy = [ "default.target" ];
    services.NetworkManager-wait-online.enable = false;
  };
  services = {
    fluxcast.enable = true;
    tailscale = {
      enable = lib.mkForce false;
      package = pkgs-stable.tailscale;
    };
    netbird = {
      enable = true;
      ui.enable = true;
    };
    resolved.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      socketActivation = false;
    };
  };

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true; # Requires v4l2loopback and polkit
    plugins = with pkgs.obs-studio-plugins; [
      droidcam-obs
    ];
  };

  networking.nameservers = [ "10.0.1.1" ];

  freedpom = {
    windowManagers.hyprland.enable = true;
    system = {
      users = {
        users = {
          ${username} = {
            role = "admin";
            userOptions = {
              packages = with pkgs; [
                zed-editor
                sone
                limo
                stremio-linux-shell
                bleachbit
              ];
              description = formatUsername username;
              hashedPasswordFile = config.age.secrets."${username}-password".path;
              shell = pkgs.zsh;
              ignoreShellProgramCheck = true;
              extraGroups = [ "gamemode" ];
              openssh.authorizedKeys.keys = [
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICU1ToHVRo5curH9yPzJPhRsf2FkqKMtroVtojTJ6IOZAAAACnNzaDpzaGluanU= slaw_dormitory861@aleeas.com"
              ];
            };
          };
        };
      };
      boot.enable = true;
    };
  };

  nixpkgs.flake.source = lib.mkForce null;

  # freedpom's ananicy sets this to false, nixpkgs's default is a conflicting true
  services.ananicy.settings.cgroup_realtime_workaround = lib.mkForce false;

  programs.ssh.knownHosts = {
    "codeberg.org" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
    };
  };
}
