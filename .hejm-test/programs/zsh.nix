_: {
  flake.modules.nixos.zsh = {
    programs.zsh.enable = true;
  };

  flake.modules.hjem.zsh =
    { config, lib, ... }:
    let
      cfg = config.programs.zsh;
    in
    {
      options.programs.zsh = {
        enable = lib.mkEnableOption "zsh shell";
      };

      config = lib.mkIf cfg.enable {
        files = {
          ".zshenv".text = ''
            if [[ -f $HOME/.zshrc ]]; then
              source $HOME/.zshrc
            fi
          '';
        };
      };
    };
}
