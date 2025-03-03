{ config, pkgs, ... }:

{
  users.users.joshua = {
    isNormalUser = true;
    description = "Joshua";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      vim
];
  };

  # Enable automatic login
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "joshua";
}
