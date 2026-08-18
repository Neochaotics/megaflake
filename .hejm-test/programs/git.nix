{ pkgs, ... }:
let
  gitIni = pkgs.formats.gitIni { listsAsDuplicateKeys = true; };
in
{
  flake.modules.nixos.git = {
    programs.git.enable = true;
  };

  flake.modules.hjem.git =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.git;
    in
    {
      options.programs.git = {
        enable = lib.mkEnableOption "git";
      };

      config = lib.mkIf cfg.enable {
        packages = [ pkgs.gh ];

        xdg.config.files."git/config" = {
          generator = gitIni.generate "config";
          value = {
            user = {
              name = "Neochaotics";
              email = "72465280+Neochaotics@users.noreply.github.com";
            };
            core.editor = "nvim";
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
            rebase.autoSquash = "true";
            push.default = "upstream";
            pull.rebase = "true";
          };
        };
      };
    };
}
