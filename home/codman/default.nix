{
  userName,
  lib,
  ...
}: let
  formatUsername = name:
    lib.strings.stringAsChars (
      c:
        if c == builtins.substring ((builtins.stringLength name) - 1) 1 name
        then " ${lib.strings.toUpper c}"
        else if c == (builtins.substring 0 1 name)
        then lib.strings.toUpper c
        else c
    )
    name;
in {
  users = {
    users.${userName} = {
      isNormalUser = true;
      description = formatUsername userName;
    };
  };

  home-manager = {
    users.${userName} = import ./home.nix;
    extraSpecialArgs = {inherit userName;};
  };
}
