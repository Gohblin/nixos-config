{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  services.printing.enable = true;
  programs.firefox.enable = true;
  system.stateVersion = "24.11";
}
