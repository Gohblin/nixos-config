{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/desktop.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/system.nix
    ./modules/packages.nix
    ./modules/extension-cleanup.nix
    ./modules/surface-resolution.nix
    ./modules/minecraft-firewall.nix
    ./modules/font-config.nix
    ./modules/zlibrary.nix
    ./modules/git.nix
    ./modules/vim-nil.nix
    
  ];

   home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.joshua = { ... }: {
      # Your home-manager config for joshua
    };
  };

   programs.vim-nil.enable = true;
   programs.zlibrary.enable = true;

   git.enable = true;
     git.userName = "Gohblin";
     git.userEmail = "literategoblin@gmail.com";

   services.minecraft-firewall = {
    enable = true;
    port = 25565;
    useTailscale = true;
  };

  system.stateVersion = "24.11";

}
