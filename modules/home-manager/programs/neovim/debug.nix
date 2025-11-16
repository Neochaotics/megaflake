{
  programs.nvf.settings = {
    vim = {
      debugger.nvim-dap = {
        enable = false;
        mappings = {
          continue = "<leader>dc"; # Continue debugging
          goDown = "<leader>dvi"; # Go down stacktrace
          goUp = "<leader>dvo"; # Go up stacktrace
          hover = "<leader>dh"; # Hover for info
          restart = "<leader>dR"; # Restart debugging session
          runLast = "<leader>d."; # Re-run last debug session
          runToCursor = "<leader>dgc"; # Continue to cursor
          stepBack = "<leader>dgk"; # Step back in stacktrace
          stepInto = "<leader>dgi"; # Step into function
          stepOut = "<leader>dgo"; # Step out of function
          stepOver = "<leader>dgj"; # Next step
          terminate = "<leader>dq"; # Terminate debugging session
          toggleBreakpoint = "<leader>db"; # Toggle breakpoint
          toggleDapUI = "<leader>du"; # Toggle DAP UI
          toggleRepl = "<leader>dr"; # Toggle REPL
        };
        sources = { };
        ui = {
          enable = true;
          autoStart = true;
          setupOpts = { };
        };
      };
    };
  };
}
