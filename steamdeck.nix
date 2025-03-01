{ config, lib, pkgs, ... }:
with lib;
let cfg = config.my.steamdeck;
in {
  options.my.steamdeck = {
    enable = mkEnableOption "Steamdeck-specific setup";

    gamescope = {
      enable = mkEnableOption "Jovian Steam gamescope session";
      user = mkOption {
        type = types.str;
        default = "deck";
      };
      bootSession = mkOption {
        type = types.str;
        default = "gamescope-wayland"; # Changed to match Jovian
      };
      desktopSession = mkOption {
        type = types.str;
        default = "plasma"; # Default desktop session
      };
    };

    opensd = {
      enable = mkEnableOption "Userspace driver for Valve's Steam Deck";
      user = mkOption { type = types.str; };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      jovian = {
        hardware.has.amd.gpu = true;
        devices.steamdeck = {
          enable = true;
          enableXorgRotation = false;
          enableDefaultCmdlineConfig = true;
          autoUpdate = false;
        };
        steamos = {
          useSteamOSConfig = false;
          enableDefaultCmdlineConfig = true;
          enableMesaPatches = false;
          enableVendorRadv = false;
        };
      };

      services.libinput = {
        enable = true;
      };

      services.xserver.videoDrivers = [ "amdgpu" ];

      boot.kernelParams = [
        "tsc=directsync"
        "module_blacklist=tpm"
        "spi_amd.speed_dev=1"
      ];

      hardware.cpu.amd.updateMicrocode = true;
      hardware.opengl.enable = true;

      services.udev.extraRules = ''
        KERNEL=="event[0-9]*", ATTRS{phys}=="usb-0000:04:00.4-3/input0", TAG+="kwin-ignore-tablet-mode"
        KERNEL=="event[0-9]*", ATTRS{name}=="extest fake device", TAG+="kwin-ignore-tablet-mode"
      '';

      hardware.pulseaudio.enable = mkIf
        (config.jovian.devices.steamdeck.enableSoundSupport
          && config.services.pipewire.enable)
        (mkForce false);

      services.fwupd.enable = true;
      environment.systemPackages = with pkgs; [
        steamdeck-firmware
        jupiter-dock-updater-bin
        plasmadeck-vapor-theme
      ];
    })
    
    (mkIf (cfg.enable && cfg.opensd.enable) {
      users.groups.opensd = { };
      users.users."${cfg.opensd.user}".extraGroups = [ "opensd" ];
      services.udev.packages = [ pkgs.opensd ];

      home-manager.users."${cfg.opensd.user}".systemd.user.services.opensd = {
        Install = { WantedBy = [ "default.target" ]; };
        Service = { ExecStart = "${getExe pkgs.opensd} -l info"; };
      };
    })
    
    (mkIf (cfg.enable && cfg.gamescope.enable) {
      # Set the default session for login
      services.displayManager.defaultSession = cfg.gamescope.bootSession;
      
      # Add a script to manually start gaming mode
      environment.systemPackages = with pkgs; [
        (writeShellScriptBin "start-steam-gamemode" ''
          #!/bin/sh
          gamescope -e -- steam -gamepadui -fulldesktopres
        '')
      ] ++ [
        (pkgs.makeAutostartItem rec {
          name = "steam";
          package = pkgs.makeDesktopItem {
            inherit name;
            desktopName = "Steam";
            exec = "steam -silent %U";
            icon = "steam";
            extraConfig = {
              OnlyShowIn = "KDE";
            };
          };
        })
      ];

      jovian = {
        steam = {
          enable = true;
          user = cfg.gamescope.user;
          autoStart = true;
          defaultSession = "gamescope-wayland"; # Explicitly set the gaming mode session
          desktopSession = cfg.gamescope.desktopSession;
          gameScope = {
            enable = true;
            args = ["-e"];  # Ensure gamescope is configured correctly
            steamArgs = ["-gamepadui"]; # Launch directly into gamepad UI
          };
        };
        decky-loader = {
          enable = true;
          user = "root";
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

      programs.steam = {
        enable = true;
        extest.enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession = {
          enable = true;
          args = ["-f"];  # Make sure gamescope session args are set
        };
      };

      # Create a systemd service to auto-start gaming mode for the deck user
      systemd.user.services.steam-gamemode = {
        description = "Steam Gaming Mode";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.steam}/bin/steam -gamepadui -fulldesktopres";
          Restart = "on-failure";
          RestartSec = "5";
        };
      };

      home-manager.users."${cfg.gamescope.user}".home.packages = with pkgs; [
        unstable.steamtinkerlaunch
        unstable.protonup-qt
        unstable.mangohud
      ];
      
      # Make sure gamescope package is installed
      environment.systemPackages = with pkgs; [
        gamescope
      ];
    })
  ];
}
