{pkgs ? import <nixpkgs> {}}: {
  antec-flux-pro-display = pkgs.stdenv.mkDerivation {
    pname = "antec-flux-pro-display";
    version = "unstable-2025-11-08";

    src = pkgs.fetchFromGitHub {
      owner = "Reikooters";
      repo = "antec-flux-pro-display";
      rev = "master";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # replace after first build
    };

    nativeBuildInputs = [
      pkgs.rustc
      pkgs.cargo
    ];

    buildPhase = ''
      cargo build --release --locked
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp target/release/antec-flux-pro-display $out/bin/
      chmod +x $out/bin/antec-flux-pro-display
    '';

    meta = with pkgs.lib; {
      description = "Rust utility for controlling the Antec Flux Pro display via USB";
      homepage = "https://github.com/Reikooters/antec-flux-pro-display";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };

  antec-flux-pro-display-udev = pkgs.stdenv.mkDerivation {
    pname = "antec-flux-pro-display-udev";
    version = "1.0.0";

    src = pkgs.writeText "99-antec-flux-pro-display.rules" ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="2022", ATTR{idProduct}=="0522", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    '';

    installPhase = ''
      mkdir -p $out/lib/udev/rules.d
      cp $src $out/lib/udev/rules.d/99-antec-flux-pro-display.rules
    '';

    meta = with pkgs.lib; {
      description = "Udev rule for Antec Flux Pro display (vendor=2022, product=0522)";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };
}
