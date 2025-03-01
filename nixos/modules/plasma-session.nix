{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    myPlasma = {
      enable = mkEnableOption "Simple Plasma 6 X11 setup without login manager";
    };
  };

  config = mkIf config.myPlasma.enable {
    # Disable all display managers
    services.xserver.displayManager.startx.enable = true;
    services.xserver.displayManager.lightdm.enable = false;
    services.xserver.displayManager.gdm.enable = false;
    services.xserver.displayManager.sddm.enable = false;

    # Enable X11 with KDE Plasma 6
    services.xserver = {
      enable = true;
      desktopManager.plasma6 = {
        enable = true;
        useQtScaling = true;
      };
    };

    # Install essential Plasma packages
    environment.systemPackages = with pkgs; [
      # Basic KDE applications
      libsForQt5.kate
      libsForQt5.kdeconnect-kde
      libsForQt5.dolphin
      libsForQt5.konsole
      
      # X11 utilities
      xorg.xinit
      xorg.xrdb
      xterm # Fallback terminal
    ];

    # Create a custom .xinitrc for users
    environment.etc."skel/.xinitrc" = {
      text = ''
        #!/bin/sh

        # Load X resources
        [ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

        # Start Plasma desktop
        exec startplasma-x11
      '';
      mode = "0555";
    };

    # Documentation for users
    environment.etc."skel/README.plasma6-x11.md" = {
      text = ''
        # Plasma 6 X11 Setup

        This system has been configured with Plasma 6 on X11 without a login manager.

        ## Starting Plasma
        To start the Plasma desktop, run:
        ```
        startx
        ```

        ## Troubleshooting
        If Plasma doesn't start properly, you can try:
        1. Checking the X logs in ~/.local/share/xorg/
        2. Running `startplasma-x11` directly
        3. Examining systemd journal with `journalctl -xe`
      '';
      mode = "0444";
    };

    # Set default session to Plasma X11
    services.xserver.displayManager.defaultSession = "plasma";
    
    # Add common fonts
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];
  };
}
