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
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.ff.nixosModules.windowManagers
    inputs.ff.nixosModules.default
    self.nixosModules.qModule
    ./disk-primary.nix
    ./disk-secondary.nix
    ./hardware.nix
  ];

  environment.systemPackages = [
    pkgs-stable.android-studio
    pkgs.pavucontrol
    pkgs.qpwgraph
    pkgs.r2modman
    #pkgs.easyeffects
    pkgs.kmon
    pkgs.gping
    pkgs.gitoxide
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
    ollama.environmentVariables = {
      HIP_VISIBLE_DEVICES = "0";
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
    flatpak.enable = true;
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  freedpom = {
    windowManagers.hyprland.enable = true;
    services = {
      ssh.enable = true;
      ntpd.enable = true;
      ananicy.enable = true;
      pipewire.enable = false;
      ollama.enable = true;
      consoles = {
        enable = true;
        getty = [
          "quinno@tty1"
          "tty3"
          "tty5"
        ];
        kmscon = [
          "tty2"
          "tty4"
        ];
        kmsconConfig = {
          font = {
            name = "monospace";
            size = 14;
          };
          hwaccel = true;
          drm = true;
          video.gpus = "primary";
          scrollbackSize = 2000;
        };
      };
      vr = {
        enable = true;
        autoStart = true;
        bitrate = 150000000;
        wivrnPkg = pkgs-stable.wivrn;
      };
    };
    system = {
      locale.enable = true;
      users = {
        users = {
          ${username} = {
            role = "admin";
            userOptions = {
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
      fonts.enable = true;
      nix.enable = true;
      sysctl = {
        cachyos = true;
        mineral = false;
      };
      boot.enable = true;
      performance.enable = true;
    };
    programs = {
      sudo-rs.enable = true;
      fuc.enable = true;
      uutils.enable = true;
    };
  };

  qm = {
    programs = {
      #hyprland.enable = true;
      steam.enable = true;
    };
    yubikey.enable = true;
    stylix.enable = true;
    antec-display = {
      enable = true;
      cpu.device = "k10temp-pci-00c3";
      gpu.device = "amdgpu-pci-0300";
    };
  };
}
