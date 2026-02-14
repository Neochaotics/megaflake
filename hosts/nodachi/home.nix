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
    mcp = {
      enable = true;
      servers = {
        nixos = {
          command = "docker";
          args = [
            "run" "--rm" "-i" "ghcr.io/utensils/mcp-nixos"
          ];
        };
      };
    };
    opencode = {
      enableMcpIntegration = false;
      settings = {
        mcp = {
          nixos = {
            type = "local";
            command = ["docker" "run" "--rm" "-i" "ghcr.io/utensils/mcp-nixos"];
            enabled = true;
          };
        };
        formatter = {
          nixfmt = {
            command = ["nix" "fmt"];
            extensions = [".nix"];
          };
        };
        permission = {
          bash= {
            "*" = "ask";
            "git *" = "allow";
            "rm *" = "deny";
            "grep *" = "allow";
          };
        };
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama";
            options = {
              baseURL = "http://localhost:11434/v1";
            };
            models = {
              qwen3-coder = {
                name = "qwen3-coder";
              };
            };
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
    #enableNixpkgsReleaseCheck = false;
    packages = with pkgs-stable; [
      zed-editor
      legcord
      tidal-hifi
      element-desktop
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
      aria2.enable = true;
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
