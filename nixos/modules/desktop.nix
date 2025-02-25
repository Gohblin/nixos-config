{ config, lib, pkgs, ... }:

{
  options = {
    # You can add custom options here if needed
  };

  config = {
    services.gnome.core-utilities.enable = true;
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

}

