_: {
  flake.modules.nixos.quinno-yazi = _: {
    hjem.users.quinno.programs.yazi = {
      enable = true;
      settings = {
        manager = {
          ratio = [
            1
            3
            2
          ];
          sort_by = "mtime";
          sort_sensitive = false;
          sort_dir_first = true;
          linemode = "size";
          show_hidden = true;
          scrolloff = 12;
        };
        preview = {
          wrap = "yes";
          tab_size = 2;
          max_width = 640;
          max_height = 480;
          image_filter = "lanczos3";
          image_quality = 75;
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
        input.cursor_blink = true;
      };
    };
  };
}
