{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.nixos.packages.util;
in
{
  options.cm.nixos.packages.util = {
    enable = lib.mkEnableOption "Enables util package installation including archives tools, search utilities, monitoring tools, system utilities and Nix-related packages";
  };

  config = lib.mkIf cfg.enable {
    environment.packages = with pkgs; [
      # archives
      zip
      xz
      unzip
      p7zip

      # utils
      ripgrep # recursively searches directories for a regex pattern
      fzf # A command-line fuzzy finder

      # nix related
      #
      # it provides the command `nom` works just like `nix`
      # with more details log output
      nix-output-monitor

      #btop  # replacement of htop/nmon
      iotop # io monitoring
      iftop # network monitoring

      # system call monitoring
      strace # system call monitoring
      ltrace # library call monitoring
      lsof # list open files

      # system tools
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb

      nil
    ];
  };
}
