# ~/.config/home-manager/surface-resolution.nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    pkgs.gnome-tweaks
    pkgs.dconf-editor
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      scaling-factor = 2;
      text-scaling-factor = 1.0;
    };
  };

  home.sessionVariables = {
    SCALE_FACTOR = "2";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };
}
