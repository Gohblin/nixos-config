{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/plasma-session.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/system.nix
    ./modules/packages.nix
    ./modules/minecraft-firewall.nix
    ./modules/font-config.nix
    ./modules/git.nix
    ./modules/nix-search.nix
    ./modules/nix-search-file.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.deck = {...}: {
      # Your home-manager config for joshua
    };
  };

  git.enable = true;
  git.userName = "Gohblin";
  git.userEmail = "literategoblin@gmail.com";

  services.nix-search-file = {
    enable = true;
    defaultSearchPath = "./";
    maxContextLines = 2;
  };

  services.snap.enable = true;
  services.minecraft-firewall = {
    enable = true;
    port = 25565;
    useTailscale = true;
  };

  myPlasma.enable = true;

  system.stateVersion = "24.11";
}
