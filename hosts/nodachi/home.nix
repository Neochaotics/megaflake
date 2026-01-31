{
  pkgs-stable,
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
      };
    };
  };

  home = {
    stateVersion = "24.05";
    inherit username;
    homeDirectory = "/home/${username}";
    #enableNixpkgsReleaseCheck = false;
    packages = with pkgs-stable; [
      zed-editor
      legcord
      tidal-hifi
      element-desktop
    ];
  };
  freedpom = {
    programs = {
      opencode.enable = true;
      bash.enable = true;
    };
    windowManagers = {
      autoStart = true;
      hyprland.enable = true;
    };
    security.gpg.enable = true;
  };

  qm = {
    programs = {
      firefox.enable = true;
      foot.enable = true;
      git.enable = true;
      utils.enable = true;
      fuzzel.enable = true;
      aria2.enable = true;
      waybar.enable = true;
      zsh.enable = true;
      starship.enable = true;
      yazi.enable = true;
      bottom.enable = true;
      nvim.enable = true;
      mpv.enable = true;
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
