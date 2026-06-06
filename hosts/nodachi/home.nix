{
  username,
  inputs,
  self,
  config,
  ...
}:
{
  imports = [
    inputs.ff.homeModules.windowManagers
    inputs.ff.homeModules.default
    self.homeModules.qModule
  ];
  programs = {
    ssh = {
      enableDefaultConfig = false;
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
  };
  freedpom = {
    programs = {
      bash.enable = true;
    };
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
      starship.enable = true;
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
