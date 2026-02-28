{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.opencode;
in
{
  options.qm.opencode = {
    enable = lib.mkEnableOption "Enable opencode AI assistant configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;

      rules = ''
        ## Decision Making

        - Act decisively without hesitation - don't ask permission for routine tasks
        - After 2-3 failed attempts at a task, stop and ask for guidance instead of looping
        - Ask for clarification when requirements are unclear or ambiguous
        - Ask for input when circumstances change or unexpected results occur
        - Provide options with recommendations when decisions are needed

        ## Security

        - Never commit secrets, keys, credentials, or tokens to any repository
        - Never use sudo unless explicitly instructed
        - Never modify permissions broadly (no chmod -R 777, no chmod -R 0)
        - Never delete files without explicit confirmation
        - Never suggest curl | sh installers
        - Never suggest global npm/pip/cargo installs
        - Treat all user data as sensitive

        ## Nix Best Practices

        - All dependencies must be managed via Nix (flake.nix, packages, etc.)
        - Prefer declarative changes over imperative fixes
        - System changes belong in flake modules or NixOS config
        - User changes belong in home-manager modules
        - Prefer nix build over language-specific build tools
        - Never modify /etc or ~/.config manually when declarative options exist

        ## Reproducibility

        - Use pinned inputs in flake.lock
        - Avoid unpinned GitHub tarball imports
        - Use fetchFromGitHub or flake inputs over ad-hoc fetches

        ## Git Workflow

        - Never push automatically
        - Commits require explicit confirmation
        - Avoid destructive commands (reset --hard, clean -fd)
        - Use conventional commit format when committing

        ## Output Style

        - Provide minimal, precise changes
        - Output valid Nix syntax when editing Nix code
        - Prefer diffs or exact snippets over vague descriptions
        - Keep responses concise (1-3 sentences unless detail is needed)
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
          description: Use nix-shell to create ad-hoc or project-based development environments
          ---

          ## What I do

          - Create ad-hoc environments with `-p`
          - Load project environments if shell.nix or default.nix exists
          - Execute commands via --run and --command
          - Start pure environments with --pure
          - Preserve variables with --keep

          ## When to use me

          - Quick temporary environments
        '';

        nix-develop = ''
          ---
          name: nix-develop
          description: Enter and manage reproducible flake-based development environments
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
          description: Interactively evaluate Nix expressions and explore nixpkgs or flake outputs
          ---

          ## What I do

          - Launch nix repl
          - Load nixpkgs or flakes
          - Inspect attribute sets
          - Evaluate expressions interactively

          ## When to use me

          - Exploring nixpkgs
          - Debugging Nix expressions
          - Inspecting flake outputs
        '';

        context7 = ''
          ---
          name: context7-doc-search
          description: Search official documentation using context7 tools
          ---

          ## What I do

          - Search official documentation sources
          - Retrieve authoritative usage references
          - Resolve uncertainty about APIs or CLI behavior

          ## When to use me

          - When documentation lookup is required
          - When behavior must be verified
          - When exact syntax matters
        '';

        gh-grep = ''
          ---
          name: gh-grep-code-search
          description: Search GitHub repositories for real-world implementation examples
          ---

          ## What I do

          - Search public GitHub repositories for code patterns
          - Find real-world configuration examples
          - Locate usage patterns in open-source projects

          ## When to use me

          - When unsure how something is implemented
          - When examples are better than documentation
        '';

        nix-query = ''
          ---
          name: nix-query-tool
          description: Query Nix packages, options, flakes, channels, and documentation
          ---

          ## What I do

          - Search packages, programs, flakes, and options
          - Retrieve detailed package or option metadata
          - Browse Home Manager and nix-darwin options
          - Explore flake inputs from the local store

          ## Interface

          nix(action, query, source, type, channel, limit)

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
        '';
      };
    };
  };
}
