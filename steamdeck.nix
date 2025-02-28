# steamdeck.nix
{ config, lib, pkgs, ... }:

{
  # Enable Steam Deck specific hardware support
  jovian.devices.steamdeck = {
    enable = true;                      # Enable Steam Deck hardware support
    autoUpdate = true;                  # Enable automatic BIOS and controller firmware updates
    enableGyroDsuService = true;        # Enable gyroscope support for emulators
    enableOsFanControl = true;          # Enable OS-controlled fan curve
  };

  # Enable Steam with Gaming Mode
  jovian.steam = {
    enable = true;                      # Enable Steam Deck UI
    autoStart = true;
    desktopSession = "gnome";                  # Automatically launch Steam Deck UI on boot
    user = "joshua";                    # The user Steam will be launched as

    # Environment variables for the gamescope session
    environment = {
      STEAM_RUNTIME_PREFER_HOST_LIBRARIES = "0";
      STEAM_FORCE_DESKTOPUI_SCALING = "1.0";
      MANGOHUD = "1";                   # Enable MangoHud by default for performance metrics
      STEAM_GAMESCOPE_HDR = "1";        # Enable HDR if available
    };

    # Use Jovian splash screen
    updater.splash = "jovian";
  };

  # Enable SteamOS-like configurations
  jovian.steamos = {
    useSteamOSConfig = true;            # Enable general SteamOS configurations
    enableBluetoothConfig = true;       # Use SteamOS Bluetooth settings
    enableZram = true;                  # Enable zram for better memory management
    enableMesaPatches = true;           # Apply Mesa patches for better performance
    enableVendorRadv = true;            # Enable vendor RADV for better AMD GPU performance
  };

  # Enable Decky Loader for plugins
  jovian.decky-loader = {
    enable = true;
    user = "joshua";
  };

  # Additional packages useful for gaming and tinkering
  environment.systemPackages = with pkgs; [
    # Gaming tools
    mangohud            # Performance overlay
    gamemode            # CPU governor optimization for gaming
    lutris              # Game manager for non-Steam games
    protontricks        # Wine prefix manager for Proton
    winetricks          # Wine prefix manager
    
    # Controller support
    input-remapper     # Tool for remapping input devices
    
    # Emulation
    retroarch          # Retro game emulation
    
    # Tinkering tools
    powertop           # Power consumption analyzer
    htop               # Process viewer
    radeontop          # GPU utilization viewer for AMD
    pciutils           # PCI utilities for hardware inspection
    usbutils           # USB utilities
    glxinfo            # OpenGL information
    vulkan-tools       # Vulkan information and tools
    
    # System recovery tools
    gparted            # Partition manager
    testdisk           # Data recovery tool
  ];
  
  # Optimize kernel parameters for gaming
  boot.kernelParams = [
    "amd_pstate=active"  # Better power management for AMD CPUs
    "amdgpu.ppfeaturemask=0xffffffff"  # Enable all AMD GPU features
    "mitigations=off"    # Disable CPU security mitigations for better performance
  ];

  # Enable better filesystem performance for games
  fileSystems = {
    # Example optimization for your root filesystem
    "/" = {
      options = [ "noatime" "nodiratime" ];
    };
  };

  # Enable Gamemode system-wide
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        amd_performance_level = "high";
      };
    };
  };

  # Better audio for gaming
  sound.extraConfig = ''
    defaults.pcm.rate_converter "speexrate_best"
  '';

  # Enable Steam-supported hardware
  hardware = {
    steam-hardware.enable = true;  # Enable the Steam hardware udev rules
    xpadneo.enable = true;         # Better Xbox controller support
    opengl = {
      enable = true;
    };
  };
}
