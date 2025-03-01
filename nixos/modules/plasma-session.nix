{ config, lib, pkgs, ... }:
with lib; {
  options.myPlasma = {
    enable = mkEnableOption "Plasma desktop fallback configuration";
  };

  config = mkIf config.myPlasma.enable {
    # Session integration with Jovian
    services.xserver.displayManager.session = [
      {
        manage = "desktop";
        name = "gamescope";
        start = "start-gamescope-session";
      }
      {
        manage = "desktop";
        name = "plasma-x11";
        start = "startplasma-x11";
      }
    ];

    # Minimal Plasma configuration
    services.desktopManager.plasma6.enable = true;

    environment.systemPackages = with pkgs; [
      libsForQt5.dolphin
      libsForQt5.konsole
      xorg.xinit
    ];

    # Font configuration
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      fira-code
    ];
  };
}

