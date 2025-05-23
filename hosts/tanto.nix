{
  config,
  pkgs,
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.ff.nixosModules.freedpomFlake
    inputs.qm.nixosModules.qModule
  ];

  # Nix-on-Droid specific settings
  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = "aarch64-linux";

  # User configuration adapted for Android
  user.shell = pkgs.zsh;
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERM = "xterm-256color";
  };

  # FF module configuration - only mobile compatible features
  ff = {
    common.enable = true;
    security.sudo-rs.enable = true;
    services.openssh.enable = true;
    system.nix.enable = true;
  };

  # QM module configuration - CLI/TUI focused
  qm = {
    programs = {
      steam.enable = false;
      hyprland.enable = false;
    };
    stylix.enable = false;
    wireguard.enable = false;
  };

  # Nix settings optimized for mobile
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "nix-on-droid"
      ];
      sandbox = true;
      cores = 4;
      max-jobs = 4;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Additional mobile-specific settings
  services.tailscale.enable = true;

  age.rekey = {
    masterIdentities = [ "/data/data/com.termux.nix/files/home/.age.key" ];
    localStorageDir = "${self}" + "/secrets/rekeyed/${config.networking.hostName}";
    generatedSecretsDir = "${self}" + "/secrets/generated/${config.networking.hostName}";
    storageMode = "local";
  };
}
