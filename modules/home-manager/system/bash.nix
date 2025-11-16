{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.system.bash;
in
{
  options.qm.system.bash = {
    enable = lib.mkEnableOption "Enable bash configuration and settings";
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historyFile = "${config.home.homeDirectory}/.bash_history";
      historyFileSize = 1000;
      historyIgnore = [
        "clear"
        "exit"
      ];
      historySize = 1000;
    };
  };
}
