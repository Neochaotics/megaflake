# gitui configuration.
#
# Ported from home-manager's `modules/programs/gitui.nix` (BSD-3-Clause, (c)
# Home Manager contributors): same defaults, file names and derivation names.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gitui;
in
{
  options.programs.gitui = {
    enable = lib.mkEnableOption "gitui";

    package = lib.mkPackageOption pkgs "gitui" { };

    theme = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.lines;
      default = ''
        (
          selected_tab: Reset,
          command_fg: White,
          selection_bg: Blue,
          selection_fg: White,
          cmdbar_bg: Blue,
          cmdbar_extra_lines_bg: Blue,
          disabled_fg: DarkGray,
          diff_line_add: Green,
          diff_line_delete: Red,
          diff_file_added: LightGreen,
          diff_file_removed: LightRed,
          diff_file_moved: LightMagenta,
          diff_file_modified: Yellow,
          commit_hash: Magenta,
          commit_time: LightCyan,
          commit_author: Green,
          danger_fg: Red,
          push_gauge_bg: Blue,
          push_gauge_fg: Reset,
          tag_fg: LightMagenta,
          branch_fg: LightYellow,
        )
      '';
      description = ''
        Theme in Ron file format. This is written to
        {file}`$XDG_CONFIG_HOME/gitui/theme.ron`.
      '';
    };

    keyConfig = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.lines;
      default = "";
      example = ''
        exit: Some(( code: Char('c'), modifiers: ( bits: 2,),)),
        quit: Some(( code: Char('q'), modifiers: ( bits: 0,),)),
        exit_popup: Some(( code: Esc, modifiers: ( bits: 0,),)),
      '';
      description = ''
        Key config in Ron file format. This is written to
        {file}`$XDG_CONFIG_HOME/gitui/key_bindings.ron`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    xdg.config.files."gitui/theme.ron".source =
      if builtins.isPath cfg.theme || lib.isStorePath cfg.theme then
        cfg.theme
      else
        pkgs.writeText "gitui-theme.ron" cfg.theme;

    xdg.config.files."gitui/key_bindings.ron".source =
      if builtins.isPath cfg.keyConfig || lib.isStorePath cfg.keyConfig then
        cfg.keyConfig
      else
        pkgs.writeText "gitui-key-config.ron" cfg.keyConfig;
  };
}
