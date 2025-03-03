{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable printing
  services.printing.enable = true;

  # Enable Firefox
  programs.firefox.enable = true;
}
