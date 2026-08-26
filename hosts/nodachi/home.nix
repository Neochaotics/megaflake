{
  username,
  self,
  config,
  pkgs,
  ...
}:
{
  imports = [
    self.homeModules.ffDefault
    self.homeModules.qModule
  ];
  programs = {
    ssh = {
      enableDefaultConfig = true;
      enable = true;
      matchBlocks = {
        github = {
          hostname = "github.com";
          identityFile = [ "${config.home.homeDirectory}/.ssh/ssh_id_ed25519_key" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "gitlab.com" = {
          hostname = "gitlab.com";
          identityFile = [ "${config.home.homeDirectory}/.ssh/id_isc_gitlab" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "codeberg.org" = {
          hostname = "codeberg.org";
          identityFile = [ "${config.home.homeDirectory}/.ssh/id_codeberg" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "capuchin-us-ne" = {
          hostname = "5.161.179.69";
          identityFile = [ "${config.home.homeDirectory}/.ssh/id_codeberg" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "kogatana" = {
          hostname = "kogatana";
          identityFile = [ "${config.home.homeDirectory}/.ssh/id_codeberg" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
      };
    };
  };

  home = {
    stateVersion = "24.05";
    inherit username;
    homeDirectory = "/home/${username}";
    pointerCursor.package = pkgs.bibata-cursors;
    pointerCursor.name = "Bibata-Modern-Amber";
    sessionVariables = {
      RADV_PERFTEST = "transfer_queue";
    };
  };
  freedpom = {
    windowManagers = {
      autoStart = true;
      hyprland.enable = true;
    };
  };

  qm = {
    opencode.enable = true;
    programs = {
      firefox.enable = true;
      foot.enable = true;
      git.enable = true;
      utils.enable = true;
      fuzzel.enable = true;
      waybar.enable = true;
      zsh.enable = true;
      yazi.enable = true;
    };
    system = {
      xdg.enable = true;
    };
    desktop = {
      hypr = {
        land.enable = true;
        idle-lock.enable = true;
        sunset.enable = true;
      };
    };
  };
}
