{ config, pkgs, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/dconf-update.nix
    ./modules/zsh.nix
    ./modules/mc-server.nix
    ./modules/zen-pwa.nix
    ./modules/nixcord.nix
    ./modules/clipboard-copy.nix
  ];

  programs.minecraft-server = {
    enable = true;
    extraPackages = with pkgs; [
      screen  
      tmux    
    ];
  };


  custom.clipboard-copy.enable = true;
  
  programs.nixcord.enable = true; 
  programs.dconf-update.enable = true;
  programs.firefox.enable = true;
  programs.zen-pwa.enable = true;


  programs.home-manager.enable = true;
}
