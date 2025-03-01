{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.my.steamdeck;
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
    jovian = {
      hardware.has.amd.gpu = true;

      devices.steamdeck = {
        enable = true;
        enableOsFanControl = true;
        enableXorgRotation = false;
        autoUpdate = false;
      };

      steamos = {
        useSteamOSConfig = true;  # Critical SteamOS integration
        enableVendorRadv = true;   # Required for AMD GPU
        enableMesaPatches = true;  # Needed for Gamescope
      };

      steam = {
        enable = true;
        user = cfg.user;
        autoStart = true;
        desktopSession = "plasma-x11";  # Proper desktop session ID
      };

      decky-loader = {
        enable = true;
        user = cfg.user;  # Changed from root to user account
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

    # Disable conflicting desktop environments
    services.xserver.desktopManager.plasma5.enable = mkForce false;

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
    };

    # Hardware configuration
    services.xserver.videoDrivers = ["amdgpu"];
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    hardware.cpu.amd.updateMicrocode = true;

    # Essential kernel parameters
    boot.kernelParams = [
      "tsc=directsync"
      "module_blacklist=tpm"
      "spi_amd.speed_dev=1"
    ];

    # Input configuration
    services.libinput.enable = true;
    services.udev.extraRules = ''
      KERNEL=="event[0-9]*", ATTRS{phys}=="usb-0000:04:00.4-3/input0", TAG+="kwin-ignore-tablet-mode"
      KERNEL=="event[0-9]*", ATTRS{name}=="extest fake device", TAG+="kwin-ignore-tablet-mode"
    '';

    # User configuration
    users.users.${cfg.user} = {
      isNormalUser = true;
      extraGroups = ["wheel" "video" "input" "audio" "networkmanager" "docker"];
    };

    # System packages
    environment.systemPackages = with pkgs; [
      steamdeck-firmware
      jupiter-dock-updater-bin
      gamescope
      (writeShellScriptBin "start-gaming-mode" ''
        exec start-gamescope-session
      '')
    ];

    # Session management
    services.displayManager.defaultSession = "gamescope";
    environment.variables.DEFAULT_X_SESSION = "gamescope";
  };
}

