{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qm.programs.git;
in
{
  options.qm.programs.git = {
    enable = lib.mkEnableOption "Enable git configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.gh ];
    programs = {
      gitui.enable = true;
      git = {
        enable = true;

        settings = {
          user = {
            name = "Neochaotics";
            email = "72465280+Neochaotics@users.noreply.github.com";
          };
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
  };
}
