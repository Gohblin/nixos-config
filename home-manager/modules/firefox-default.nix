# ~/.config/nixpkgs/modules/firefox-default.nix

{ config, lib, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "Default";
        isDefault = true;
      };
    };
  };
}

