{ config, pkgs, ... }:

{
  users.users.joshua = {
    isNormalUser = true;
    description = "Joshua";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  programs.zsh.enable = true;

  home-manager.users.joshua = { pkgs, ... }: {
    home.username = "joshua";
    home.homeDirectory = "/home/joshua";
    home.stateVersion = "24.11";
  };

}
