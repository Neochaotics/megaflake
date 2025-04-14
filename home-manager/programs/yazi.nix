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
          ratio = [
            1
            3
            2
          ]; # 1/6 width for parent, 3/6 width for current, 2/6 width for preview
          sort_by = "mtime";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "size";
          show_hidden = true;
          show_symlink = true;
          scrolloff = 12;
        };
        preview = {
          wrap = "yes";
          tab_size = 2;
          max_width = 640;
          max_height = 480;
          image_filter = "lanczos3";
          image_quality = 75;
          sixel_fraction = 10;
        };
        input = {
          cursor_blink = true;
        };
        opener = {
          play = [
            {
              run = "mpv \"$@\"";
              orphan = true;
              for = "unix";
            }
          ];
          edit = [
            {
              run = "$EDITOR \"$@\"";
              block = true;
              for = "unix";
            }
          ];
          open = [
            {
              run = "xdg-open \"$@\"";
              desc = "Openz";
            }
          ];
        };
      };
    };
  };
}
