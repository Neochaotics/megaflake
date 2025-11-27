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
    inputs.chaotic.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.ff.nixosModules.freedpomFlake
    self.nixosModules.qModule
    ./disk-primary.nix
    ./disk-secondary.nix
    ./hardware.nix
  ];

  environment.systemPackages = with pkgs; [
    android-studio
    pavucontrol
  ];

  age = {
    rekey = {
      agePlugins = [ pkgs.age-plugin-yubikey ];
      hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDX9AJIAYoQF1zAXtRkxhdJuxAkn00rfayPC1B0aoIXy root@titan";
      masterIdentities = [
        {
          identity = "AGE-PLUGIN-YUBIKEY-1GDE3QQ5ZEC6RA6G62VFSN";
          pubkey = "age1yubikey1q296zd6ksfpqufd68us8x75mfyc45qtytsvphhj65y9az6th3z8c2kd7987";
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

  users = {
    users = {
      ${username} = {
        isNormalUser = true;
        description = formatUsername username;
        hashedPasswordFile = config.age.secrets."${username}-password".path;
        #initialPassword = "password";
        shell = pkgs.zsh;
        ignoreShellProgramCheck = true;
        extraGroups = [
          "wheel"
        ]
        ++ lib.optional config.security.rtkit.enable "rtkit"
        ++ lib.optional config.services.pipewire.enable "audio"
        ++ lib.optional config.services.pipewire.enable "pipewire"
        ++ lib.optional config.hardware.i2c.enable "i2c";
      };
    };
    mutableUsers = lib.mkForce false;
  };

  home-manager = {
    users.${username} = import ./home.nix;
    extraSpecialArgs = { inherit username inputs self; };
    backupFileExtension = "bk";
    useGlobalPkgs = true;
    useUserPackages = true;
  };
  security.rtkit.enable = true;
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];
  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      socketActivation = false;
    };

    #blueman.enable = true;
    getty.autologinUser = "${username}";
    tailscale.enable = lib.mkForce true;
    flatpak.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "tampermonkey"
    ];

  #programs.obs-studio = {
  #  enable = true;
  #  enableVirtualCamera = true;
  #  plugins = with pkgs.obs-studio-plugins; [
  #    droidcam-obs
  #  ];
  #;

  #programs.coolercontrol.enable = true;

  ff = {
    common.enable = true;
    services = {
      ntp.enable = true;
      ananicy.enable = true;
      pipewire.enable = false;
      openssh.enable = true;
      ollama.enable = false;
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
          "tty6"
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
      virt-reality = {
        enable = true;
        autoStart = true;
        bitrate = 150000000;
        wivrnPkg = pkgs-stable.wivrn;
      };
    };
    system = {
      rust-utils = {
        sudo-rs.enable = true;
        fuc.enable = true;
        uutils.enable = true;
      };
      fontsu.enable = true;
      nix.enable = true;
      sysctl = {
        cachyos = true;
        mineral = false;
      };
      boot.enable = true;
      performance.enable = true;
    };
  };

  qm = {
    programs = {
      hyprland.enable = true;
      steam.enable = true;
    };
    yubikey.enable = true;
    stylix.enable = true;
    wireguard.enable = true;
    antec-display = {
      enable = true;
      cpu.device = "k10temp-pci-00c3";
      gpu.device = "amdgpu-pci-0300";
    };
  };
}
