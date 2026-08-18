_: {
  flake.modules.nixos.quinno-fuzzel = _: {
    hjem.users.quinno.programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "no";
          prompt = "'  '";
          placeholder = "...";
          match-mode = "fuzzy";
          width = 60;
          lines = 6;
          anchor = "top";
          y-margin = 240;
          horizontal-pad = 30;
          vertical-pad = 12;
          inner-pad = 3;
          launch-prefix = "uwsm app --";
        };
        border = {
          width = 2;
          radius = 6;
        };
      };
    };
  };
}
