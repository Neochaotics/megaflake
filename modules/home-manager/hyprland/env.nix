{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland.enable {
    env = [
      "XDG_CURRENT_DESKTOP, Hyprland" # Current desktop name
      "XDG_SESSION_DESKTOP, Hyprland" # Session desktop name
      "XDG_SESSION_TYPE, wayland" # Use Wayland session
      "GDK_BACKEND, wayland, x11" # GTK backend order
      "CLUTTER_BACKEND, wayland" # Clutter backend
      "QT_QPA_PLATFORM=wayland;xcb" # Qt backend (Wayland, fallback to X11)
      "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1" # No Qt window borders
      "SDL_VIDEODRIVER, x11" # SDL uses X11
      "QT_AUTO_SCREEN_SCALE_FACTOR, 1" # Qt auto scaling
      "QT_SCALE_FACTOR,1" # Qt scale factor
      "GDK_SCALE,1" # GTK scale factor
      "MOZ_ENABLE_WAYLAND, 1" # Enable Wayland in Firefox
      "ELECTRON_OZONE_PLATFORM_HINT,wayland" # Electron Wayland hint
      "EDITOR,nvim" # Default editor
      "TERMINAL,foot" # Default terminal
      "XDG_TERMINAL_EMULATOR,foot" # Terminal emulator name
      "NIXOS_OZONE_WL, 1" # Ozone support in Chromium apps
      "NIXPKGS_ALLOW_UNFREE, 1" # Allow unfree packages
    ];
  };
}
