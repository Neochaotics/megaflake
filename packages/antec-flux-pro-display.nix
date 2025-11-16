{ pkgs }:
pkgs.rustPlatform.buildRustPackage {
  pname = "antec-flux-pro-display";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "Reikooters";
    repo = "antec-flux-pro-display";
    rev = "059e512e843232825866cec28c96d1ff1637ae67";
    sha256 = "sha256-T/Q1oroxprJqMnEN3nb/lyOqaQKHZjNTY7kGFHp0trw=";
  };

  buildInputs = [ pkgs.lm_sensors ];
  cargoHash = "sha256-GR/ZcT1v1Tv4KAfD+IldhkYwz0kaT/lhN6wXtMbmO9o=";

  meta = with pkgs.lib; {
    description = "Rust utility for controlling the Antec Flux Pro display via USB";
    homepage = "https://github.com/Reikooters/antec-flux-pro-display";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
