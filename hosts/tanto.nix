{
  inputs,
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
}
