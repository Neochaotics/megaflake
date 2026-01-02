{
  lib,
  inputs,
  pkgs,
  self,
  config,
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
    inputs.ff.nixosModules.freedpomFlake
    self.nixosModules.qModule
    ./disks.nix
    ./hardware.nix
  ];

  age = {
    rekey = {
      agePlugins = [ pkgs.age-plugin-yubikey ];
      #hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDX9AJIAYoQF1zAXtRkxhdJuxAkn00rfayPC1B0aoIXy root@titan";
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

  home-manager = {
    users.${username} = import ./home.nix;
    extraSpecialArgs = { inherit username inputs self; };
    backupFileExtension = "bk";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  ff = {
    userConfig = {
      users = {
        ${username} = {
          role = "admin";
          userOptions = {
            description = formatUsername username;
            #hashedPasswordFile = config.age.secrets."${username}-password".path;
            initialPassword = "password";
            shell = pkgs.zsh;
            ignoreShellProgramCheck = true;
            openssh.authorizedKeys.keys = [
              "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICU1ToHVRo5curH9yPzJPhRsf2FkqKMtroVtojTJ6IOZAAAACnNzaDpzaGluanU= slaw_dormitory861@aleeas.com"
            ];
          };
        };
      };
    };
    common.enable = true;
    services = {
      ntp.enable = true;
      ananicy.enable = true;
      openssh.enable = true;
      consoles = {
        enable = true;
        getty = [
          "${username}@tty1"
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
          #video.gpus = "primary";
          scrollbackSize = 2000;
        };
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
    stylix.enable = true;
  };
}
