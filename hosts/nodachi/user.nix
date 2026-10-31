{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
let
  username = config.constants.username;
  formatUsername =
    name:
    lib.strings.stringAsChars (
      c:
      if c == builtins.substring ((builtins.stringLength name) - 1) 1 name then
        " ${lib.strings.toUpper c}"
      else if c == (builtins.substring 0 1 name) then
        lib.strings.toUpper c
      else
        c
    ) name;

in
{
  hjem = {
    clobberByDefault = true;
    users.${username} = import ./hjem.nix;
    extraModules = [
      # Module collection (hyprland, foot, fuzzel, git, yazi, hyprlock, ...)
      inputs.hjem-rum.hjemModules.default
      # Local modules (bash, zsh, ssh, firefox, systemd user units, ...)
      self.modules.hjem.default
      # Opencode via freedpom's single consolidated hjem module
      # (config + tooling + skills; v2 schema, opencode/big-pickle default).
      inputs.freedpom.modules.hjem.opencode
    ];
    # hjem modules cannot see flake inputs by default.
    specialArgs.inputs = inputs;
  };

  freedpom = {
    windowManagers.hyprland.enable = true;
    system = {
      users = {
        users = {
          ${username} = {
            role = "admin";
            userOptions = {
              packages = with pkgs; [
                zed-editor
                sone
                #limo
                stremio-linux-shell
                bleachbit
              ];
              description = formatUsername username;
              hashedPasswordFile = config.age.secrets."${username}-password".path;
              shell = pkgs.zsh;
              ignoreShellProgramCheck = true;
              extraGroups = [ "gamemode" ];
              openssh.authorizedKeys.keys = [
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICU1ToHVRo5curH9yPzJPhRsf2FkqKMtroVtojTJ6IOZAAAACnNzaDpzaGluanU= slaw_dormitory861@aleeas.com"
              ];
            };
          };
        };
      };
      boot.enable = true;
    };
  };

}
