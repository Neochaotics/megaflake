{ # nix run github:nix-community/nixos-anywhere -- --flake /etc/nixos#kozuka --disk-encryption-keys /tmp/secret.key <(rage -d -i <(echo "AGE-PLUGIN-YUBIKEY-1DCRWKQVZK894T4GARVMJX") pass.age) --target-host root@10.0.1.218
  lib,
  inputs,
  pkgs,
  self,
  config,
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
    inputs.ff.nixosModules.default
    self.nixosModules.qModule
    ./disks.nix
    ./hardware.nix
  ];

  age = {
    rekey = {
      agePlugins = [ pkgs.age-plugin-yubikey ];
      #hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDX9AJIAYoQF1zAXtRkxhdJuxAkn00rfayPC1B0aoIXy root@titan";
      masterIdentities = [
        { # Shinju
          identity = "AGE-PLUGIN-YUBIKEY-1GDE3QQ5ZLTSN3QSS37XZ7";
          pubkey = "age1yubikey1qdvsf3r75px0rcdc035uyzk4wnul223dxkpcgsj4qt4pnsy6dcfv5wkxgyk";
        }
        { # Kagami
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

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  freedpom = {
    services = {
      ssh.enable = true;
      ntpd.enable = true;
      ananicy.enable = true;
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
    programs = {
      sudo-rs.enable = true;
      fuc.enable = true;
      uutils.enable = true;
    };
    system = {
      users = {
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
      fonts.enable = true;
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
