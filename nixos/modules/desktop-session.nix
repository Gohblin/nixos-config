{
  config,
  pkgs,
  ...
}: {
  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable GNOME desktop environment
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  # Set GNOME as default session (optional, but helps ensure it's properly registered)
  services.displayManager.defaultSession = "gnome";
}
