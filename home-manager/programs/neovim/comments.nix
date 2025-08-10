{
  programs.nvf.settingsvim.comments.comment-nvim = {
    enable = true;

    mappings = {
      toggleCurrentBlock = "gbc";
      toggleCurrentLine = "gcc";
      toggleOpLeaderBlock = "gb";
      toggleOpLeaderLine = "gc";
      toggleSelectedBlock = "gb";
      toggleSelectedLine = "gc";
    };

    setupOpts = {
      mappings = {
        basic = false;
        extra = false;
      };
    };
  };
}
