{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/base.nix
    ./modules/hardware.nix
    ./modules/desktop.nix
    ./modules/git.nix
    #./modules/steamos.nix
    ./modules/user-config.nix
    ./modules/workarounds.nix
  ];

  git.enable = true;
  git.userName = "Gohblin";
  git.userEmail = "literategoblin@gmail.com"

}
