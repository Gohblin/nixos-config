{ config, pkgs, lib, ... }: {
  home.packages = with pkgs.gnomeExtensions; [
    blur-my-shell
    dash-to-dock
    pop-shell
    rounded-window-corners-reborn
    transparent-top-bar-adjustable-transparency
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "blur-my-shell@aunetx"          # UUID for blur-my-shell
        "dash-to-dock@micxgx.gmail.com" 
        "pop-shell@system76.com"
        "rounded-window-corners@yilozt" # UUID for rounded-window-corners-reborn
        "transparent-top-bar@zhanghai.me"
      ];
    };

    # Extension-specific configurations remain the same
    "org/gnome/shell/extensions/blur-my-shell" = {
      sigma = 30;
      brightness = 0.6;
      color = lib.gvariant.mkTuple [0.0 0.0 0.0 0.0];
    };
    
    "org/gnome/shell/extensions/dash-to-dock" = {
      transparency-mode = "FIXED";
      background-opacity = 0.0;
    };
  };
}

