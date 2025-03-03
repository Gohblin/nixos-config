{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/clipboard-copy.nix
  ];

  # Define the state version for Home Manager
  home.stateVersion = "24.11";

  # Add Home Manager-specific configurations
  home.packages = with pkgs; [
    steam
    firefox
  ];

  custom.clipboard-copy.enable = true;
  programs.zsh.enable = true;
  programs.git.enable = true;
}

