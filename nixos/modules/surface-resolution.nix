{
  config,
  lib,
  pkgs,
  ...
}: {
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;

    # Enable Wayland
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  # Configure system-wide scaling for Wayland
  environment.sessionVariables = {
    WEBKIT_SCALE = "1.75";
    GDK_SCALE = "1.75";
    QT_SCALE_FACTOR = "1.75";
    # Force some apps to use Wayland
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # GNOME settings via dconf
  programs.dconf.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.mutter]
    experimental-features=['scale-monitor-framebuffer']

    [org.gnome.desktop.interface]
    text-scaling-factor=1.25
    scaling-factor=uint32 2

    [org.gnome.settings-daemon.plugins.xsettings]
    overrides={'Gdk/WindowScalingFactor': <2>}
  '';
}
