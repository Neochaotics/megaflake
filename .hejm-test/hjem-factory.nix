{ config, ... }: {
  config.flake.modules.nixos.hjem-collection = _: {
    hjem.extraModules = builtins.attrValues config.flake.modules.hjem;
  };
}
