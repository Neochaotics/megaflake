{
  description = "Collection of NixOS and Home-Manager presets";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fpFmt = {
      url = "github:freedpom/FreedpomFormatter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ff = {
      #url = "path:/home/quinno/github/freedpom/FreedpomFlake";
      url = "github:freedpom/FreedpomFlake";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.home-manager.follows = "home-manager";
    };

    #obsidian-nvim.url = "github:epwalsh/obsidian.nvim";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.obsidian-nvim.follows = "obsidian-nvim";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&rev=8ca0845762f7a664b1d5a920ef3bd03df50311d0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [
        inputs.home-manager.flakeModules.home-manager
        inputs.fpFmt.flakeModule
      ];
      flake = {
        nixosModules = {
          qModule = ./modules/nixos;
        };
        homeModules = {
          qModule = ./modules/home-manager;
        };
      };
    };
}
