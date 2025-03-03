{ config, pkgs, lib, ... }:

{
  # Enable Steam Deck specific hardware support
  jovian.devices.steamdeck = {
    enable = true;                      # Enable Steam Deck hardware support
    autoUpdate = true;                  # Auto-update BIOS and controller firmware
    enableGyroDsuService = true;        # Enable gyroscope support for compatible games
  };

  # Enable Steam Deck UI with auto-start
  jovian.steam = {
    enable = true;                      # Enable Steam Deck UI
    autoStart = true;                   # Auto-start the Steam Deck UI on boot
    desktopSession = "gnome";           # Use GNOME for desktop mode
    user = "deck";                      # Set the Steam user
  };

  # Enable SteamOS-like configurations
  jovian.steamos = {
    useSteamOSConfig = true;            # Enable SteamOS configurations
  };

  # Optional: Enable Decky Loader for plugins
  jovian.decky-loader = {
    enable = true;
    user = "deck";
  };

  # Set up the user account
  users.users.deck = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" "audio" "gamemode" ];
    initialPassword = "steamdeck";      # Change this after installation
  };

  # GNOME desktop environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Graphics drivers
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;             # Needed for Steam games
  };

  # Audio support
  sound.enable = true;
  hardware.pulseaudio.enable = false;   # We'll use pipewire instead
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth support
  hardware.bluetooth.enable = true;

  # Power management
  powerManagement.enable = true;
  services.thermald.enable = true;      # Temperature monitoring

  # Regular Steam client for desktop mode
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Network configuration
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 27036 27037 ]; # Steam Remote Play
      allowedUDPPorts = [ 27031 27036 ]; # Steam Remote Play
    };
  };

  # Touchscreen and input support
  services.xserver.libinput.enable = true;

  # Gamemode for optimizing game performance
  programs.gamemode.enable = true;

  # Enable firmware updates
  services.fwupd.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # System tools
    vim
    wget
    git
    htop
    
    # Gaming related
    mangohud                # Display FPS and system stats in games
    lutris                  # Game launcher for non-Steam games
    protontricks            # Winetricks for Proton
    protonup-qt             # Proton GE manager
    
    # Desktop utilities
    gnome.gnome-tweaks
    flatpak                 # For installing apps like Heroic Game Launcher
  ];

  # Enable flatpak service
  services.flatpak.enable = true;

  # Boot loader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Use the latest kernel for best hardware support
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Set your time zone
  time.timeZone = "America/New_York"; # Change to your timezone

  # Set your locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = false; # Set to true if you want automatic upgrades
    allowReboot = false;
  };

  # Set system state version
  system.stateVersion = "23.11"; # Use your NixOS version here
}
