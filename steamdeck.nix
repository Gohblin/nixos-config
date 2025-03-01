{ config, lib, pkgs, ... }:
with lib;
let cfg = config.my.steamdeck;
in {
  options.my.steamdeck = {
    enable = mkEnableOption "Steamdeck-specific setup";
    user = mkOption {
      type = types.str;
      default = "deck";
      description = "User for Steam Deck and gaming mode";
    };
  };

  config = mkIf cfg.enable {
    # Basic Steam Deck hardware setup
    jovian = {
      # Hardware configuration
      hardware.has.amd.gpu = true;
      
      # Steam Deck specific setup
      devices.steamdeck = {
        enable = true;
        enableXorgRotation = false; # Unfix X11 rotation (drivers fix it)
        enableDefaultCmdlineConfig = true;
        autoUpdate = false;
      };
      
      # SteamOS configuration
      steamos = {
        useSteamOSConfig = false;
        enableDefaultCmdlineConfig = true;
        enableMesaPatches = false;
        enableVendorRadv = false;
      };
      
      # Steam and Gamescope configuration (key part from documentation)
      steam = {
        enable = true;
        user = cfg.user;
        autoStart = true; # Enable auto-start at boot (preferred way per docs)
        desktopSession = "plasma"; # Switch to Desktop goes to Plasma
      };
      
      # Enable Decky Loader
      decky-loader = {
        enable = true;
        user = "root"; # Recommended by Jovian-NixOS
        extraPackages = with pkgs; [
          curl
          unzip
          util-linux
          gnugrep
          readline.out
          procps
          pciutils
          libpulseaudio
        ];
      };
    };

    # Enable Plasma desktop environment
    services.xserver.desktopManager.plasma5.enable = true;
    
    # Enable regular Steam for desktop mode
    programs.steam = {
      enable = true;
      extest.enable = true; # X11->Wayland SteamInput mapping
      remotePlay.openFirewall = true;
      gamescopeSession.enable = true;
    };

    # GPU drivers and hardware support
    services.xserver.videoDrivers = [ "amdgpu" ];
    hardware.opengl.enable = true;
    hardware.cpu.amd.updateMicrocode = true;
    
    # Steam Deck specific kernel parameters
    boot.kernelParams = [
      "tsc=directsync"
      "module_blacklist=tpm"
      "spi_amd.speed_dev=1"
    ];

    # Input support
    services.libinput.enable = true;
    
    # Ignore built-in trackpad as a desktop input
    services.udev.extraRules = ''
      KERNEL=="event[0-9]*", ATTRS{phys}=="usb-0000:04:00.4-3/input0", TAG+="kwin-ignore-tablet-mode"
      KERNEL=="event[0-9]*", ATTRS{name}=="extest fake device", TAG+="kwin-ignore-tablet-mode"
    '';

    # Sound support
    hardware.pulseaudio.enable = mkIf
      (config.jovian.devices.steamdeck.enableSoundSupport
        && config.services.pipewire.enable)
      (mkForce false);
    
    # Firmware and utilities
    services.fwupd.enable = true;
    environment.systemPackages = with pkgs; [
      steamdeck-firmware
      jupiter-dock-updater-bin
      plasmadeck-vapor-theme
      gamescope # Ensure gamescope is installed
      
      # Add a helper script for manual gaming mode launch
      (writeShellScriptBin "start-gaming-mode" ''
        #!/bin/sh
        exec start-gamescope-session
      '')
    ];
    
    # Create a user if it doesn't exist
    users.users.${cfg.user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "input" "audio" "dialout" ];
      # You may want to set a password or SSH keys here
    };
    
    # Add Steam-related packages to the user
    home-manager.users.${cfg.user}.home.packages = with pkgs; [
      mangohud
      protonup-qt
      gamemode
    ];
  };
}
