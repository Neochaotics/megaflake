{
  lib,
  config,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.zsh;
in
{
  options.cm.home.users.quinno.programs.zsh = {
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
      initExtra = ''
        if uwsm check may-start; then
          exec uwsm start -S hyprland-uwsm.desktop
        fi
      '';
    };
  };
}
