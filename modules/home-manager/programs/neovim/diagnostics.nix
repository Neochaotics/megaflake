{ lib, ... }:
{
  programs.nvf.settings = {
    vim.diagnostics = {
      enable = true;

      config = {
        signs = {
          text = lib.generators.mkLuaInline ''
            {
              [vim.diagnostic.severity.ERROR] = "󰅚 ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.INFO] = " ",
              [vim.diagnostic.severity.HINT] = "󰌵 ",
            }
          '';
        };
        underline = true;
        update_in_insert = false;
        virtual_lines = false;
        virtual_text = {
          format = lib.generators.mkLuaInline ''
            function(diagnostic)
              return string.format("%s (%s)", diagnostic.message, diagnostic.source)
            end
          '';
        };
      };

      nvim-lint = {
        enable = true;
        lint_after_save = true;
        linters_by_ft = {
          bash = [ "shellcheck" ];
          javascript = [ "eslint_d" ];
          lua = [ "luacheck" ];
          markdown = [ "markdownlint-cli2" ];
          nix = [
            "statix"
            "deadnix"
          ];
          ruby = [ "rubocop" ];
          svelte = [ "eslint_d" ];
          typescript = [ "eslint_d" ];
        };
      };
    };
  };
}
