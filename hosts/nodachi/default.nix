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
    inputs.agenix-rekey.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
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

  home-manager = {
    users.${username} = import ./home.nix;
    extraSpecialArgs = {
      inherit
        username
        inputs
        self
        pkgs-stable
        ;
    };
    backupFileExtension = "bk";
    useGlobalPkgs = true;
    useUserPackages = true;
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

  systemd = {
    user.services.wireplumber.wantedBy = [ "default.target" ];
    services.NetworkManager-wait-online.enable = false;
  };
  services = {
    tailscale = {
      enable = lib.mkForce true;
      package = pkgs-stable.tailscale;
    };
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
