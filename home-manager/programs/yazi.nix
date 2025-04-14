{ lib, config, ... }:
let
  cfg = config.qm.programs.yazi;
in
{
  options.qm.programs.yazi = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          ratio = [1 4 3]; # 1/8 width for parent, 4/8 width for current, 3/8 width for preview
          sort_by = "mtime";
          sort_sensitive=false;
          sort_reverse=false;
          sort_dir_first=true;
        };
      };
    };
  };
}
