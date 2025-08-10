{
  programs.nvf.settings.vim.binds = {
    cheatsheet = {
      enable = true;
    };

    hardtime-nvim = {
      enable = true;
      setupOpts = {};
    };

    whichKey = {
      enable = true;
      register = {};
      setupOpts = {
        notify = true;
        preset = "modern";
        win = {
          border = "rounded";
        };
      };
    };
  };
}
