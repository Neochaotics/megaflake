_: {
  flake.modules.nixos.quinno-foot = _: {
    hjem.users.quinno.programs.foot = {
      enable = true;
      settings = {
        main.font = "OverpassM Nerd Font Mono:size=18";
        cursor.blink = true;
      };
    };
  };
}
