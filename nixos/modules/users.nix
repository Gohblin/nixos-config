{ config, pkgs, ... }:

{
  users.users.deck = {
    isNormalUser = true;
    description = "Deck";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  programs.zsh.enable = true;

  home-manager.users.deck = { pkgs, ... }: {
    home.username = "deck";
    home.homeDirectory = "/home/deck";
    home.stateVersion = "24.11";
  };

}
