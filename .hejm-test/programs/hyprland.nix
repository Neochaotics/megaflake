{ pkgs, ... }:
{
  flake.modules.hjem.hyprland =
    { config, lib, ... }:
    let
      cfg = config.programs.hyprland;
    in
    {
      options.programs.hyprland = {
        enable = lib.mkEnableOption "Hyprland Wayland compositor";
        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
        };
        extraConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
        };
      };

      config = lib.mkIf cfg.enable {
        packages = [ pkgs.hyprland ];

        environment.sessionVariables = {
          EDITOR = "nvim";
          TERMINAL = "foot";
        };

        xdg.config.files."hypr/hyprland.conf".text =
          lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              section: values:
              if builtins.isList values then
                lib.concatMapStringsSep "\n" (v: "${section} = ${builtins.toString v}") values
              else if builtins.isAttrs values then
                "${section} {\n"
                + lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (
                    k: v:
                    if builtins.isAttrs v then
                      "  ${k} {\n"
                      + lib.concatStringsSep "\n" (lib.mapAttrsToList (k2: v2: "    ${k2} = ${builtins.toString v2}") v)
                      + "\n  }"
                    else
                      "  ${k} = ${builtins.toString v}"
                  ) values
                )
                + "\n}"
              else if section == "bind" || section == "bindm" || section == "windowrule" then
                lib.concatMapStringsSep "\n" (v: "${section} = ${v}") values
              else
                "${section} = ${builtins.toString values}"
            ) cfg.settings
          )
          + lib.optionalString (cfg.extraConfig != "") "\n${cfg.extraConfig}";
      };
    };
}
