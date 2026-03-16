{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.programs.starship;
in
{
  options.qm.programs.starship = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        continuation_prompt = "[▸▹ ](dimmed white)";

        format = lib.concatStrings [
          "($nix_shell$fill)"
          "$character"
        ];

        right_format = lib.concatStrings [
          "$directory"
          "$git_branch"
          "$git_status"
          "$cmd_duration"
        ];

        fill = {
          symbol = " ";
        };

        character = {
          format = "$symbol ";
          success_symbol = "[▸](bold green)";
          error_symbol = "[✗](bold red)";
          vimcmd_symbol = "[](italic dimmed green)";
          vimcmd_replace_one_symbol = "[r](italic dimmed green)";
          vimcmd_replace_symbol = "[R](italic dimmed green)";
          vimcmd_visual_symbol = "[v](italic dimmed green)";
        };

        nix_shell = {
          style = "bold italic dimmed blue";
          symbol = "⬡ ";
          format = "[$symbol $name]($style) ";
          impure_msg = "[⬡ impure](dimmed red)";
          pure_msg = "[⬡ pure](dimmed green)";
        };

        cmd_duration = {
          format = "[⏱ $duration](dimmed white) ";
        };

        directory = {
          home_symbol = "~";
          truncation_length = 3;
          truncation_symbol = "…/";
          read_only = " 🔒";
          use_os_path_sep = true;
          style = "blue italic";
          format = "[$path]($style)[$read_only]($read_only_style)";
          repo_root_style = "bold blue";
          repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style)";
        };

        git_branch = {
          format = "[⚙ $branch](bold blue) ";
          symbol = "";
          style = "bold blue";
          truncation_symbol = "…";
          truncation_length = 12;
          only_attached = false;
        };

        git_status = {
          style = "bold yellow";
          format = "[$staged$modified$untracked$renamed$deleted$conflicted$stashed]($style)";
          conflicted = "[⚠](bold red)";
          ahead = "[↑](bold green)";
          behind = "[↓](bold red)";
          diverged = "[↕](bold red)";
          untracked = "[○](dimmed yellow)";
          stashed = "[◆](dimmed white)";
          modified = "[●](bold yellow)";
          staged = "[+](bold green)";
          renamed = "[→](bold blue)";
          deleted = "[✗](bold red)";
        };

        python = {
          symbol = "🐍 ";
          format = "[$symbol]($style) ";
          style = "bold yellow";
        };

        rust = {
          symbol = "🦀 ";
          format = "[$symbol]($style) ";
          style = "bold red";
        };

        nodejs = {
          symbol = "⬢ ";
          format = "[$symbol]($style) ";
          style = "bold green";
        };

        golang = {
          symbol = "go ";
          format = "[$symbol]($style) ";
          style = "bold cyan";
        };

        java = {
          symbol = "☕ ";
          format = "[$symbol]($style) ";
          style = "bold red";
        };

        docker_context = {
          symbol = "🐳 ";
          format = "[$symbol]($style) ";
          style = "bold blue";
        };

        package = {
          symbol = "📦 ";
          format = "[$symbol]($style) ";
          style = "bold yellow";
        };

        aws = {
          disabled = true;
        };

        gcloud = {
          disabled = true;
        };

        azure = {
          disabled = true;
        };

        time = {
          disabled = true;
        };

        username = {
          disabled = true;
        };

        localip = {
          disabled = true;
        };

        battery = {
          disabled = true;
        };

        memory_usage = {
          disabled = true;
        };

        jobs = {
          disabled = true;
        };

        sudo = {
          disabled = true;
        };
      };
    };
  };
}
