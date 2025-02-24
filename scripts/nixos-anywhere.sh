nix run github:nix-community/nixos-anywhere -- --flake ../nixosconf#libvirt --target-host root@192.168.122.207 # --disk-encryption-keys /boot/disk.key <(sops --extract '["luks_key"]' -d "./modules/nixos/system/secrets/general.yaml")

age --decrypt -i /persist/age.key ./secrets/generated/gem/crypt.age

nix run github:nix-community/nixos-anywhere -- --flake ../nixos#gem --target-host root@192.168.1.196 --disk-encryption-keys /run/agenix/crypt <(age --decrypt -i /persist/age.key ./secrets/generated/gem/crypt.age)
