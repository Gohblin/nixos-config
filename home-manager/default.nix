{ config, pkgs, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/files.nix
    ./modules/session.nix
    ./modules/shell.nix
    ./modules/kitty.nix
    ./modules/dconf.nix
    ./modules/dconf-update.nix
    ./modules/zsh.nix
    ./modules/mc-server.nix
    ./modules/windsurf.nix
    ./modules/focuswriter-resolution.nix
    ./modules/zen-pwa.nix
    ./modules/hotkey.nix
    ./modules/nixcord.nix
    ./modules/clipboard-copy.nix
  ];

  programs.minecraft-server = {
    enable = true;
    extraPackages = with pkgs; [
      screen  # Optional: if you want to run servers in screen
      tmux    # Optional: if you prefer tmux
    ];
  };


  custom.clipboard-copy.enable = true;
  
  programs.nixcord.enable = true; 
  programs.dconf-update.enable = true;
  programs.firefox.enable = true;
  programs.zen-pwa.enable = true;


  programs.home-manager.enable = true;
}
