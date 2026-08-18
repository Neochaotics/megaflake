_: {
  flake.modules.nixos.xdg = {
    xdg.portal.enable = true;
  };

  flake.modules.hjem.xdg =
    { config, lib, ... }:
    let
      cfg = config.programs.xdg;
    in
    {
      options.programs.xdg = {
        enable = lib.mkEnableOption "XDG directory configuration";
      };

      config = lib.mkIf cfg.enable {
        files.".local/share/applications".directory = true;
        files.".local/share/fonts".directory = true;
        files.".local/state".directory = true;
        files.SCREENSHOTS.directory = true;
      };
    };
}
