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

  inherit (config.lib.stylix) colors;

  elementTheme = {
    name = "Stylix";

    is_dark = lib.hasInfix "dark" (builtins.toString config.stylix.base16Scheme);

    colors = {
      accent-color = colors.base0D;
      primary-color = colors.base0D;
      warning-color = colors.base08;

      sidebar-color = colors.base01;

      roomlist-background-color = colors.base00;
      roomlist-text-color = colors.base05;
      roomlist-text-secondary-color = colors.base04;
      roomlist-highlights-color = colors.base02;
      roomlist-separator-color = colors.base03;

      timeline-background-color = colors.base00;
      timeline-text-color = colors.base05;
      timeline-text-secondary-color = colors.base04;
      timeline-highlights-color = colors.base02;

      secondary-content = colors.base04;
      tertiary-content = colors.base03;
      quinary-content = colors.base02;

      reaction-row-button-selected-bg-color = colors.base0D;
      menu-selected-color = colors.base02;
      icon-button-color = colors.base04;

      accent = colors.base0D;
      alert = colors.base08;

      username-colors = [
        colors.base08
        colors.base09
        colors.base0A
        colors.base0B
        colors.base0C
        colors.base0D
        colors.base0E
        colors.base0F
      ];

      avatar-background-colors = [
        colors.base08
        colors.base09
        colors.base0A
        colors.base0B
        colors.base0C
        colors.base0D
        colors.base0E
        colors.base0F
      ];
    };
  };

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

      default_theme = "custom-Stylix";

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
        enableEventIndexing = false; # Message Search Cache
        showAvatarChanges = false;
        showDisplaynameChanges = false;
        showJoinLeaves = false;
        custom_themes = [
          elementTheme
        ];
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
    self.nixosModules.ffDefault
    inputs.freedpom.modules.nixos.ntpd
    inputs.freedpom.modules.nixos.locale
    inputs.freedpom.modules.nixos.ananicy
    inputs.freedpom.modules.nixos.daemon
    inputs.freedpom.modules.nixos.performance
    self.nixosModules.qModule
    ./disk-primary.nix
    ./disk-secondary.nix
    ./hardware.nix
  ];

  environment.systemPackages = with pkgs; [
    pavucontrol
    podman-compose
    r2modman
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

  networking.networkmanager.enable = true;

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
    services = {
      ssh.enable = true;
    };
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
              ];
              description = formatUsername username;
              hashedPasswordFile = config.age.secrets."${username}-password".path;
              shell = pkgs.zsh;
              ignoreShellProgramCheck = true;
              openssh.authorizedKeys.keys = [
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICU1ToHVRo5curH9yPzJPhRsf2FkqKMtroVtojTJ6IOZAAAACnNzaDpzaGluanU= slaw_dormitory861@aleeas.com"
              ];
            };
          };
        };
      };
      boot.enable = true;
    };
    programs = {
      sudo-rs.enable = true;
    };
  };

  qm = {
    programs = {
      steam.enable = true;
    };
    stylix.enable = true;
  };

  services.ananicy.settings.cgroup_realtime_workaround = lib.mkForce false;
}
