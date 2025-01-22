{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.git;
in
{
  options.cm.home.users.quinno.programs.git = {
    enable = lib.mkEnableOption "Enable git configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.gh ];

    programs.git = {
      enable = true;

      userName = "Neochaotics";
      userEmail = "neochaotics@pm.me";

      extraConfig = {
        core = {
          editor = "nvim";
        };
        color = {
          diff = "auto";
          interactive = "auto";
          pager = "true";
          status = "auto";
          branch = "auto";
          ui = "true";
        };
        rerere = {
          enabled = "true";
          autoupdate = "true";
        };
        rebase = {
          autoSquash = "true";
        };
        push.default = "upstream";
        pull.rebase = "true";
      };
    };
  };
}
