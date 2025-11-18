{
  # nix run github:nix-community/nixos-anywhere -- --flake /etc/nixos#kozuka --target-host root@10.0.1.245
  lib,
  inputs,
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
    inputs.chaotic.nixosModules.default
    inputs.ff.nixosModules.freedpomFlake
    self.nixosModules.qModule
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware.nix
  ];
  users = {
    users.${username} = {
      isNormalUser = true;
      description = formatUsername username;
      #hashedPasswordFile = config.sops.secrets.qpassword.path;
      initialPassword = "password";
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      extraGroups = [
        "wheel"
      ];
    };
    mutableUsers = false;
  };

  services.getty.autologinUser = "${username}";
  ff = {
    common.enable = true;
    system = {
      nix.enable = true;
      systemd-boot.enable = true;
    };
  };
}
