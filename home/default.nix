{ inputs, lib, ... }:
let
  userName = "quinno";
in

{

  options.userImport = {
    ${userName}.enable = lib.mkEnableOption "Enable ${userName}'s configuration";
  };

  imports = [
    inputs.impermanence.homeManagerModules.impermanence
    inputs.ff.homeManagerModules.freedpomFlake
    inputs.qm.homeManagerModules.qModule
  ];
}
