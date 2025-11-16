{ pkgs }:
pkgs.writeTextFile {
  name = "antec-flux-pro-display-udev";
  destination = "/lib/udev/rules.d/99-antec-flux-pro-display.rules";
  text = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="2022", ATTR{idProduct}=="0522", MODE="0666", GROUP="plugdev", TAG+="uaccess"
  '';
}
