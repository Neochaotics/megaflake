{
  lib,
  config,
  ...
}: let
  cfg = config.qm.programs.zsh;
in {
  options.qm.programs.zsh = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      history = {
        ignoreAllDups = true;
        ignoreSpace = true;
        size = 1000;
      };
      syntaxHighlighting.enable = true;
      autocd = true;
      enableCompletion = true;
      profileExtra = ''
        # Only try to launch Hyprland if we're on TTY1
        if [[ "$(tty)" == "/dev/tty1" ]] && uwsm check may-start; then
          exec uwsm start -S hyprland-uwsm.desktop
        fi
      '';
    };
  };
}
