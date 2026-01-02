{
  pkgs,
  username,
  inputs,
  self,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.ff.homeModules.freedpomFlake
    self.homeModules.qModule
    inputs.niri.homeModules.niri
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
    niri = {
      enable = true;
      #package = lib.mkForce pkgs.niri-stable;
      settings = {
        binds = {
          "Mod+R".action.spawn = "fuzzel";
        };
      };
    };
  };

  home = {
    stateVersion = "24.05";
    inherit username;
    homeDirectory = "/home/${username}";
    #enableNixpkgsReleaseCheck = false;
    packages = with pkgs; [
      zed-editor
      legcord
      kmon
      gping
      gitoxide
      tidal-hifi
    ];
  };
  ff = {
    gpg.enable = true;
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
    desktop = {
      hypr = {
        land.enable = true;
        idle-lock.enable = true;
        sunset.enable = true;
      };
    };
  };
}
