# hjem modules for this configuration.
#
# Import through `flake.hjemModules.default`. `rum.*` options come from
# hjem-rum (foot, fuzzel, git, yazi, hyprlock, hypridle); everything else is
# defined here.
{
  ...
}:
{
  imports = [
    ./desktop/hyprland
    ./desktop/hypridle.nix
    ./desktop/hyprsunset.nix
    ./desktop/waybar.nix
    ./home
    ./programs/bash.nix
    ./programs/eza.nix
    ./programs/firefox.nix
    ./programs/firefox-search.nix
    ./programs/fzf.nix
    ./programs/gitui.nix
    ./programs/ssh.nix
    ./programs/ssh-agent.nix
    ./programs/yazi-integration.nix
    ./programs/zoxide.nix
    ./programs/zsh.nix
    ./system/fontconfig.nix
    ./system/pointer-cursor.nix
    ./system/session-env.nix
    ./system/session-paths.nix
    ./system/systemd-user.nix
    ./system/uwsm.nix
    ./system/xdg.nix
  ];
}
