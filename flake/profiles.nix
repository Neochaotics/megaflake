{ inputs, ... }:
{
  flake.modules.nixos = {
    profile-system-base = {
      imports = with inputs.self.modules.nixos; [
        boot
        fuc
        networking
        ssh
        sudo-rs
        sysctl
        users
        uutils
      ];
    };

    profile-desktop =
      { lib, pkgs, ... }:
      {
        imports = with inputs.self.modules.nixos; [
          profile-system-base
          displays
          hyprland
          uwsm-session
        ];

        security.rtkit.enable = true;

        systemd = {
          user.services.wireplumber.wantedBy = [ "default.target" ];
          services.NetworkManager-wait-online.enable = false;
        };

        services = {
          resolved.enable = true;
          pipewire = {
            enable = true;
            alsa = {
              enable = true;
              support32Bit = true;
            };
            pulse.enable = true;
            socketActivation = false;
          };
        };

        programs.obs-studio = {
          enable = true;
          enableVirtualCamera = true; # Requires v4l2loopback and polkit
          plugins = with pkgs.obs-studio-plugins; [
            droidcam-obs
          ];
        };

        # freedpom's ananicy sets this to false, nixpkgs's default is a conflicting true
        services.ananicy.settings.cgroup_realtime_workaround = lib.mkForce false;

        programs.ssh.knownHosts = {
          "codeberg.org" = {
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
          };
        };
      };

    profile-gaming =
      { lib, ... }:
      {
        # Gamemode: boost games to nice -10 + desktop notification on start/stop.
        # steam.nix already enables the service; these are the tunables.
        programs.gamemode.settings = {
          general = {
            renice = 10;
            softrealtime = "auto";
          };
          custom = {
            start = "hyprctl notify 5 3000 0 'GameMode started'";
            end = "hyprctl notify 6 3000 0 'GameMode ended'";
          };
        };

        # Gamescope WSI: enables Vulkan WSI layer for native HDR games
        programs.gamescope.enableWsi = true;
        # Disable setcap wrapper — Steam's bwrap sandbox can't inherit capabilities
        # ("failed to inherit capabilities: Operation not permitted")
        programs.gamescope.capSysNice = lib.mkForce false;
      };

    ffDefault = {
      imports = with inputs.self.modules.nixos; [
        profile-desktop
        paseo
      ];
    };
  };
}
