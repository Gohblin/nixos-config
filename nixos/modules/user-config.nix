{ config, pkgs, ... }:

{
  users.users.deck = {
    isNormalUser = true;
    description = "Deck";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      vim
];
  };

  # Enable automatic login
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "deck";
}
