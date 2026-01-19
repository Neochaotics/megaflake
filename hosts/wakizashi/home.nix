{
  pkgs-stable,
  inputs,
  username,
  self,
  config,
  ...
}:
{
  imports = [
    inputs.ff.homeModules.ff
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
      legcord
      tidal-hifi
    ];
  };
  ff = {
    programs = {
      bash.enable = true;
    };
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
  };
}
