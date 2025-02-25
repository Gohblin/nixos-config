{
  config,
  pkgs,
  ...
}: {
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs.gnomeExtensions; [
    transparent-top-bar-adjustable-transparency
    rounded-window-corners-reborn
    dash-to-dock
    blur-my-shell
    pop-shell
  ];

  # Global dconf settings
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.shell]
    enabled-extensions=['transparent-top-bar@zhanghai.me', 'rounded-window-corners@yilozt', 'dash-to-dock@micxgx.gmail.com', 'blur-my-shell@aunetx', 'pop-shell@system76.com']

    [org.gnome.shell.extensions.transparent-top-bar]
    transparency=0
    transparency-force=true

    [org.gnome.shell.extensions.rounded-window-corners]
    custom-rounded-corner-settings=[{'name': 'FocusWriter', 'padding': {'top': 35}}]
    global-rounded-corner-settings=true

    [org.gnome.shell.extensions.dash-to-dock]
    transparency-mode='FIXED'
    background-opacity=0.0
    customize-alphas=true
    min-alpha=0.0
    max-alpha=0.0

    [org.gnome.shell.extensions.blur-my-shell]
    sigma=30
    brightness=0.6
    color=(0.0, 0.0, 0.0, 0.0)
    noise-amount=0
    noise-lightness=0
  '';
}
