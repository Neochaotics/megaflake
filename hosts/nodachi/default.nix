{
  lib,
  config,
  pkgs,
  ...
}: let
  username = "quinno";
  formatUsername = name:
    lib.strings.stringAsChars (
      c:
        if c == builtins.substring ((builtins.stringLength name) - 1) 1 name
        then " ${lib.strings.toUpper c}"
        else if c == (builtins.substring 0 1 name)
        then lib.strings.toUpper c
        else c
    )
    name;
in {
  imports = [
    ./disk-primary.nix
    ./disk-secondary.nix
    ./hardware.nix
  ];

  #age = {
  #  rekey = {
  #    masterIdentities = ["/persist/age.key"];
  #    localStorageDir = "${self}" + "/secrets/rekeyed/${config.networking.hostName}";
  #    generatedSecretsDir = "${self}" + "/secrets/generated/${config.networking.hostName}";
  #    storageMode = "local";
  #  };
  #};

  users = {
    users.${username} = {
      # User Configuration
      isNormalUser = true;
      description = formatUsername username;
      #hashedPasswordFile = config.sops.secrets.qpassword.path;
      initialPassword = "password";
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      extraGroups =
        [
          "wheel"
        ]
        ++ lib.optional config.security.rtkit.enable "rtkit"
        ++ lib.optional config.services.pipewire.enable "audio"
        ++ lib.optional config.hardware.i2c.enable "i2c";
    };
    mutableUsers = lib.mkForce true;
  };

  services.getty.autologinUser = "${username}";
  home-manager = {
    users.${username} = import ./home.nix;
    extraSpecialArgs = {inherit username;};
  };

  services.tailscale.enable = true;

  ff = {
    common.enable = true;
    security = {
      sudo-rs.enable = true;
    };
    services = {
      ananicy.enable = true;
      pipewire.enable = true;
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
      };
    };
    system = {
      fontsu.enable = true;
      nix.enable = true;
      sysctl = {
        cachyos = true;
        mineral = false;
      };
      systemd-boot.enable = true;
      performance.enable = true;
    };
  };

  qm = {
    programs = {
      hyprland.enable = true;
      steam.enable = true;
    };
    stylix.enable = true;
    wireguard.enable = false;
  };
}
