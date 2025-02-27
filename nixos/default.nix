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
    ./modules/nix-search.nix
    ./modules/nix-search-file.nix
    ./modules/blackbox-optimizations.nix
    ./modules/pieces-os-fix.nix
    #./modules/ubuntu-snap.nix
    ./modules/swdice.nix  # Changed from absolute path to relative path
    
  ];

   home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.joshua = { ... }: {
      # Your home-manager config for joshua
    };
  };

   programs.blackbox-terminal = {
    enable = true;
    highPriority = true;
    gpuAcceleration = true;
    memoryLimit = 1000; # Increase to 1GB if needed
  };

   programs.swdice.enable = true;
   programs.nixPackageSearch.enable = true;
   programs.vim-nil.enable = true;
   programs.zlibrary.enable = true;

   git.enable = true;
     git.userName = "Gohblin";
     git.userEmail = "literategoblin@gmail.com";


    services.nix-search-file = {
      enable = true;
      defaultSearchPath = "./"; # Changed from absolute path to relative path
      maxContextLines = 2; # Show 2 lines before and after match
   };

   services.snap.enable = true;
   services.minecraft-firewall = {
    enable = true;
    port = 25565;
    useTailscale = true;
  };

  system.stateVersion = "24.11";

}
