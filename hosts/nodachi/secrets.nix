{
  config,
  pkgs,
  self,
  ...
}:
let
  username = "quinno";
in
{
  age = {
    rekey = {
      agePlugins = [ pkgs.age-plugin-yubikey ];
      hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDX9AJIAYoQF1zAXtRkxhdJuxAkn00rfayPC1B0aoIXy root@titan";
      masterIdentities = [
        {
          # Shinju
          identity = "AGE-PLUGIN-YUBIKEY-1GDE3QQ5ZLTSN3QSS37XZ7";
          pubkey = "age1yubikey1qdvsf3r75px0rcdc035uyzk4wnul223dxkpcgsj4qt4pnsy6dcfv5wkxgyk";
        }
        {
          # Kagami
          identity = "AGE-PLUGIN-YUBIKEY-1DCRWKQVZK894T4GARVMJX";
          pubkey = "age1yubikey1qfrkl29gapd5n0fxvfwwws5dkvtteh36wm46dekl4srdpk3x3evvguzryz6";
        }
      ];
      localStorageDir = "${self}" + "/secrets/rekeyed/${config.networking.hostName}";
      generatedSecretsDir = "${self}" + "/secrets/generated/${config.networking.hostName}";
      storageMode = "local";
    };
    secrets = {
      "${username}-password" = {
        rekeyFile = "${self}" + "/secrets/users/${username}/pass.age";
      };
    };
  };
}
