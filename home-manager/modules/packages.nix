{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.obsidian
    pkgs.focuswriter
    pkgs.blackbox-terminal
  ];
}
