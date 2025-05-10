{
  programs.nvf.settings = {
    vim = {
      diagnostics = {
        enable = false;
        config = {
          signs.text = {
            "vim.diagnostic.severity.ERROR" = " ";
            "vim.diagnostic.severity.WARN" = " ";
          };
          underline = true;
          update_in_insert = false;
          virtual_lines = true;
          virtual_text = true;
        };
        nvim-lint = {
          enable = true;
          lint_after_save = true;
        };
      };
    };
  };
}
