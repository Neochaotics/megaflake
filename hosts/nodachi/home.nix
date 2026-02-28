{
  pkgs-stable,
  username,
  inputs,
  self,
  config,
  ...
}:
{
  imports = [
    inputs.ff.homeModules.windowManagers
    inputs.ff.homeModules.default
    self.homeModules.qModule
  ];
  programs = {
    opencode = {
      enableMcpIntegration = false;
      rules = ''
        # Nix Project Rules

        ## Core Principles

        - Prefer declarative changes over imperative fixes.
        - Do not suggest curl | sh installers.
        - Do not suggest global npm, pip, cargo, or language-level installs.
        - All dependencies must be managed via Nix.
        - Assume flakes are enabled unless the project clearly is not using them.

        ## Dependency Management

        - Use flake.nix for project dependencies.
        - Prefer nix build over language-specific build tooling when possible.
        - Never modify system state outside Nix without explicit instruction.

        ## NixOS & Home Manager

        - System changes go in flake modules.
        - User-level changes go in home-manager modules.
        - Do not suggest manual edits in /etc or ~/.config when they can be declarative.

        ## Reproducibility

        - Avoid mutable workflows.
        - Prefer pinned inputs in flake.lock.
        - Do not suggest unpinned GitHub tarball imports.
        - Prefer fetchFromGitHub or flake inputs over ad-hoc fetches.

        ## Git Workflow

        - Never push automatically.
        - Commits require explicit confirmation.
        - Avoid destructive commands (reset --hard, clean -fd).

        ## Containers

        - Prefer podman over docker.
        - Prefer declarative container definitions when possible.
        - Do not pull or push images without confirmation.

        ## Security

        - Never use sudo unless explicitly instructed.
        - Do not modify permissions broadly (no chmod -R 777).
        - Do not delete files without confirmation.

        ## File Loading

        - Only read files when necessary for the current task.
        - Do not scan the entire repository without reason.
        - Treat referenced files as authoritative for the task.

        ## Output Style

        - Provide minimal, precise changes.
        - When editing Nix code, output valid Nix syntax.
        - Prefer diffs or exact snippets over vague descriptions.

        ## Tools
        - When you need to search docs, use `context7` tools.
        - If you are unsure how to do something, use `gh_grep` to search code examples from GitHub.

        - If you need nix info use:
            nix - Unified Query Tool
            nix(action, query, source, type, channel, limit)

            Action 	What it does
            search 	Search packages, options, programs, or flakes
            info 	Get detailed info about a package or option
            stats 	Get counts and categories
            options 	Browse Home Manager/Darwin options by prefix
            channels 	List available NixOS channels
            flake-inputs 	Explore local flake inputs from Nix store
            cache 	Check binary cache status for packages

            Source 	What it queries
            nixos 	Packages, options, programs
            home-manager 	Home Manager options
            darwin 	nix-darwin options
            flakes 	Community flakes (search.nixos.org)
            flakehub 	FlakeHub registry (flakehub.com)
            nixvim 	Nixvim Neovim configuration options
            noogle 	Nix function signatures and docs (noogle.dev)
            wiki 	NixOS Wiki articles (wiki.nixos.org)
            nix-dev 	Official Nix documentation (nix.dev)
            nixhub 	Package metadata and store paths (nixhub.io)
      '';
      skills = {

        conventional-commits = ''
          ---
          name: conventional-commits
          description: Create properly formatted Conventional Commit messages
          ---

          ## What I do

          - Generate Conventional Commit messages
          - Infer commit type from changes
          - Suggest breaking change notes
          - Keep commits atomic and scoped

          ## Format

          <type>(<scope>): <short summary>

          [optional body]

          [optional footer]

          ## Allowed Types

          - feat: A new feature
          - fix: A bug fix
          - docs: Documentation changes
          - style: Formatting, no logic changes
          - refactor: Code restructuring without behavior change
          - perf: Performance improvements
          - test: Adding or updating tests
          - build: Build system or dependency changes
          - ci: CI configuration changes
          - chore: Maintenance tasks

          ## Rules

          - Summary must be lowercase
          - No trailing period
          - Keep summary under 72 characters
          - Use body to explain why, not what
          - Add BREAKING CHANGE: in footer if applicable
          - Never run git commit automatically
          - Always show the final commit message for confirmation
        '';

        nix-build-check = ''
          ---
          name: nix-build-check
          description: Safely validate and build Nix flakes and NixOS systems
          ---

          ## What I do

          - Propose nix flake check before builds
          - Suggest nix build for packages and outputs
          - Suggest nh os build for NixOS configurations
          - Help interpret build errors
          - Encourage safe validation before switching systems

          ## Preferred Workflow

          1. Run nix flake check
          2. Run nix build for the specific output
          3. Use nh os build for system builds
          4. Only switch systems after successful validation

          ## Rules

          - Never run system switches automatically
          - Prefer builds before activation
          - Highlight evaluation errors clearly
          - Do not update flake.lock unless explicitly requested
          - Show full commands before execution
        '';

        nix-shell = ''
          ---
          name: nix-shell
          description: Use nix-shell to create ad-hoc or project-based development environments including pure shells, command execution, and environment control
          license: MIT
          compatibility: opencode
          metadata:
            audience: developers
            tool: nix
            era: legacy
          ---

          ## What I do

          - Create ad-hoc environments with `-p`
          - Load project environments if `shell.nix` or `default.nix` exists
          - Execute commands via `--run` and `--command`
          - Start pure environments with `--pure`
          - Preserve variables with `--keep`
          - Debug dependency builds with `--exclude`
          - Support shebang-based nix-shell scripts

          ## When to use me

          - Quick temporary environments
        '';

        nix-develop = ''
          ---
          name: nix-develop
          description: Enter and manage reproducible flake-based development environments using nix develop
          license: MIT
          compatibility: opencode
          metadata:
            audience: developers
            tool: nix
            era: flakes
          ---

          ## What I do

          - Enter flake devShells
          - Target named devShell outputs
          - Execute commands inside devShells

          ## When to use me

          - Reproducible development environments
        '';

        nix-repl = ''
          ---
          name: nix-repl
          description: Interactively evaluate Nix expressions and explore nixpkgs or flake outputs using nix repl
          license: MIT
          compatibility: opencode
          metadata:
            audience: advanced-users
            tool: nix
          ---

          ## What I do

          - Launch nix repl
          - Load nixpkgs or flakes
          - Inspect attribute sets
          - Evaluate expressions interactively
          - Debug attribute path and evaluation errors

          ## When to use me

          - Exploring nixpkgs
          - Debugging Nix expressions
          - Inspecting flake outputs interactively
        '';

        context7 = ''
          ---
          name: context7-doc-search
          description: Search and retrieve official documentation using context7 tools when authoritative docs are required
          license: MIT
          compatibility: opencode
          metadata:
            audience: agents
            tool: context7
          ---

          ## What I do

          - Search official documentation sources
          - Retrieve authoritative usage references
          - Resolve uncertainty about APIs or CLI behavior
          - Prefer primary documentation over assumptions

          ## When to use me

          - When documentation lookup is required
          - When behavior must be verified
          - When exact syntax matters
          - When authoritative references are preferred over examples
        '';

        gh-grep = ''
          ---
          name: gh-grep-code-search
          description: Search GitHub repositories for real-world implementation examples using gh_grep
          license: MIT
          compatibility: opencode
          metadata:
            audience: agents
            tool: gh_grep
          ---

          ## What I do

          - Search public GitHub repositories
          - Find real-world configuration examples
          - Locate usage patterns in open-source projects
          - Validate common implementation approaches

          ## When to use me

          - When unsure how something is implemented in practice
          - When examples are better than documentation
          - When debugging patterns used in the ecosystem
          - When searching for working config snippets
        '';

        nix-query = ''
          ---
          name: nix-query-tool
          description: Query Nix packages, options, flakes, channels, and documentation using the unified nix query interface
          license: MIT
          compatibility: opencode
          metadata:
            audience: agents
            tool: nix
          ---

          ## What I do

          - Search packages, programs, flakes, and options
          - Retrieve detailed package or option metadata
          - Browse Home Manager and nix-darwin options
          - Explore flake inputs from the local store
          - Inspect binary cache availability
          - Query official and community documentation sources

          ## Interface

          `nix(action, query, source, type, channel, limit)`

          ### Actions

          - search — Search packages, options, programs, flakes
          - info — Detailed metadata for a package or option
          - stats — Counts and category summaries
          - options — Browse options by prefix
          - channels — List available NixOS channels
          - flake-inputs — Explore local flake inputs
          - cache — Check binary cache status

          ### Sources

          - nixos — Packages, options, programs
          - home-manager — Home Manager options
          - darwin — nix-darwin options
          - flakes — Community flakes
          - flakehub — FlakeHub registry
          - nixvim — Nixvim configuration options
          - noogle — Nix function documentation
          - wiki — NixOS Wiki
          - nix-dev — Official Nix documentation
          - nixhub — Package metadata and store paths

          ## When to use me

          - When Nix-specific information is required
          - When searching nixpkgs or options
          - When verifying flake inputs
          - When checking cache availability
          - When browsing Home Manager or nix-darwin options
        '';

      };
      settings = {
        mcp = {
          nixos = {
            type = "local";
            command = [
              "docker"
              "run"
              "--rm"
              "-i"
              "ghcr.io/utensils/mcp-nixos"
            ];
            enabled = true;
          };
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
            enabled = true;
          };
          gh_grep = {
            type = "remote";
            url = "https://mcp.grep.app";
            enabled = true;
          };
        };
        formatter = {
          nixfmt = {
            command = [
              "nix"
              "fmt"
            ];
            extensions = [ ".nix" ];
          };
        };

        permission = {
          bash = {
            "*" = "ask";

            "ls *" = "allow";
            "pwd" = "allow";
            "tree *" = "allow";
            "stat *" = "allow";
            "du *" = "allow";
            "file *" = "allow";
            "sleep *" = "allow";

            "cat *" = "allow";
            "less *" = "allow";
            "head *" = "allow";
            "tail *" = "allow";

            "grep *" = "allow";
            "sed *" = "allow";
            "awk *" = "allow";
            "sort *" = "allow";
            "tee *" = "allow";
            "rg *" = "allow";
            "ag *" = "allow";
            "find *" = "allow";

            "whoami" = "allow";
            "uname *" = "allow";
            "which *" = "allow";
            "env" = "allow";
            "nix --version" = "allow";

            "git status *" = "allow";
            "git log *" = "allow";
            "git diff *" = "allow";
            "git show *" = "allow";
            "git branch" = "allow";
            "git branch *" = "allow";
            "git remote -v" = "allow";
            "git config --get *" = "allow";

            "git add *" = "ask";
            "git restore *" = "ask";
            "git checkout *" = "ask";
            "git switch *" = "ask";
            "git merge *" = "ask";
            "git rebase *" = "ask";
            "git commit *" = "ask";
            "git tag *" = "ask";
            "git stash *" = "ask";
            "git pull *" = "ask";
            "git fetch *" = "ask";

            "git push *" = "deny";
            "git reset --hard *" = "deny";
            "git clean -fd *" = "deny";

            "npm list *" = "allow";
            "npm view *" = "allow";

            "npm install *" = "ask";
            "npm update *" = "ask";
            "npm uninstall *" = "ask";

            "nix search *" = "allow";
            "nix flake show *" = "allow";
            "nix flake metadata *" = "allow";
            "nix path-info *" = "allow";
            "nix-store --query *" = "allow";
            "nix-channel --list" = "allow";

            "nix build *" = "ask";
            "nix develop *" = "ask";
            "nix-shell *" = "ask";
            "nix run *" = "ask";

            "make *" = "ask";
            "just *" = "ask";
            "cargo build *" = "ask";
            "cargo test *" = "ask";
            "cargo run *" = "ask";
            "go build *" = "ask";
            "go test *" = "ask";

            "podman ps *" = "allow";
            "podman images *" = "allow";
            "podman inspect *" = "allow";
            "podman logs *" = "allow";

            "podman build *" = "ask";
            "podman run *" = "ask";
            "podman pull *" = "ask";
            "podman push *" = "ask";
            "podman stop *" = "ask";
            "podman start *" = "ask";
            "podman rm *" = "ask";
            "podman rmi *" = "ask";

            "curl -I *" = "allow";
            "ping *" = "allow";

            "rm *" = "ask";
            "sudo *" = "ask";
            "chmod *" = "ask";
            "chown *" = "ask";
            "dd *" = "deny";
            "mkfs *" = "deny";
            "shutdown *" = "deny";
            "reboot" = "deny";
          };
        };
      };
    };
    ssh = {
      enableDefaultConfig = false;
      enable = true;
      matchBlocks = {
        github = {
          hostname = "github.com";
          identityFile = [ "${config.home.homeDirectory}/.ssh/ssh_id_ed25519_key" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
      };
    };
  };

  home = {
    stateVersion = "24.05";
    inherit username;
    homeDirectory = "/home/${username}";
    packages = with pkgs-stable; [
      zed-editor
      legcord
      tidal-hifi
      element-desktop
      limo
      deskflow
    ];
  };
  freedpom = {
    programs = {
      opencode.enable = true;
      bash.enable = true;
    };
    windowManagers = {
      autoStart = true;
      hyprland.enable = true;
    };
    security.gpg.enable = true;
  };

  qm = {
    programs = {
      firefox.enable = true;
      foot.enable = true;
      git.enable = true;
      utils.enable = true;
      fuzzel.enable = true;
      aria2.enable = false;
      waybar.enable = true;
      zsh.enable = true;
      starship.enable = true;
      yazi.enable = true;
      bottom.enable = true;
      nvim.enable = true;
      mpv.enable = true;
    };
    system = {
      xdg.enable = true;
    };
    desktop = {
      hypr = {
        land.enable = true;
        idle-lock.enable = true;
        sunset.enable = true;
      };
    };
  };
}
