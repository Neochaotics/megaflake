{
  imports = [
    ./firefox.nix
    ./foot.nix
    ./git.nix
    ./utils.nix
    ./fuzzel.nix
    ./waybar.nix
    ./zsh.nix
    ./yazi.nix
  ];

  xdg.userDirs.setSessionVariables = true;
}
