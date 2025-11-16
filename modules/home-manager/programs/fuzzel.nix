{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.programs.fuzzel;
in
{
  options.qm.programs.fuzzel = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "no";
          prompt = "'  '";
          placeholder = "...";
          fields = "filename,keywords,generic,name";
          match-mode = "fuzzy";
          width = 60;
          lines = 6;
          anchor = "top";
          y-margin = 240;
          horizontal-pad = 30;
          vertical-pad = 12;
          inner-pad = 3;
        };
        border = {
          width = 2;
          radius = 6;
        };
      };
    };
  };
}
