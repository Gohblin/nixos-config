{ config, pkgs, ... }:

{
  jovian.devices.steamdeck.enable = true;
  
  jovian.hardware.has.amd.gpu = true;
  
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "deck";
  };
  
  jovian.steamos.useSteamOSConfig = true;
  
  jovian.decky-loader.enable = true;
  
  # 1. Login as the user running Steam
  # 2. Run: touch ~/.steam/steam/.cef-enable-remote-debugging
  
   jovian.decky-loader.user = "deck";
   jovian.decky-loader.stateDir = "/var/lib/decky-loader";
   jovian.decky-loader.extraPackages = [];
}
