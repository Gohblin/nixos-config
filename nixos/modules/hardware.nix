{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ]; # Keep hardware scan results here

  # Enable sound with Pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
