{
  imports = [
    ./default/hardware/displays.nix
    ./default/programs/fuc.nix
    ./default/programs/sudo-rs.nix
    ./default/programs/uutils.nix
    ./default/services/networking.nix
    ./default/services/paseo.nix
    ./default/services/ssh-nixos.nix
    ./default/system/boot.nix
    ./default/system/sysctl.nix
    ./default/system/users.nix
    ./windowManagers/hyprland/hyprland-nixos.nix
  ];
}
