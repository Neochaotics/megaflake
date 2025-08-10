{
  lib,
  inputs,
  config,
  pkgs,
  self,
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
    inputs.ff.nixosModules.freedpomFlake
    inputs.qm.nixosModules.qModule
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  age = {
    rekey = {
      masterIdentities = [ "/persist/age.key" ];
      localStorageDir = "${self}" + "/secrets/rekeyed/${config.networking.hostName}";
      generatedSecretsDir = "${self}" + "/secrets/generated/${config.networking.hostName}";
      storageMode = "local";
    };
  };

  users = {
    users.${username} = {
      # User Configuration
      isNormalUser = true;
      description = formatUsername username;
      #hashedPasswordFile = config.sops.secrets.qpassword.path;
      initialPassword = "password";
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      extraGroups = [
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
    extraSpecialArgs = { inherit username; };
  };

  # System Configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";

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
    };
    system = {
      nix.enable = true;
      sysctl = {
        cachyos = true;
      };
      systemd-boot.enable = true;
    };
  };

  # Custom Module Configuration
  qm = {
    programs = {
      hyprland.enable = true;
    };
    stylix.enable = true;
  };
}
