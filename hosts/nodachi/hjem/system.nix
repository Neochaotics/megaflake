{
  pkgs,
  ...
}:
{
  system.session = {
    enable = true;
    variables.RADV_PERFTEST = "transfer_queue";
  };

  services.sshAgent.enable = true;

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig.SCREENSHOTS = "/home/quinno/Pictures/Screenshots";
    };

    mimeApps.enable = true;
  };

  fonts.fontconfig.enable = true;

  packages = with pkgs; [
    gh
    nil
    nixd
    wireguard-tools
    nvd
    nix-output-monitor
    p7zip
    unzip
    xz
    ungoogled-chromium
    man-db
    xdg-user-dirs
  ];
}
