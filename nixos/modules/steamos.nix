{ config, pkgs, lib, jovian, ... }:

{
  # Steam Deck configurations
  jovian.devices.steamdeck.enable = true;
  jovian.steam.enable = true;
  jovian.steam.autoStart = true;
  jovian.steam.desktopSession = "gnome";
  jovian.steam.user = "joshua";

}
