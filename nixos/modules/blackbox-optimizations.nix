{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.blackbox-terminal;
in {
  options.programs.blackbox-terminal = {
    enable = mkEnableOption "Custom optimizations for Blackbox Terminal";
    
    highPriority = mkOption {
      type = types.bool;
      default = true;
      description = "Give Blackbox Terminal higher CPU priority";
    };
    
    gpuAcceleration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GPU acceleration for Blackbox Terminal";
    };
    
    memoryLimit = mkOption {
      type = types.int;
      default = 500;
      description = "Memory limit in MB for Blackbox Terminal";
    };
  };

  config = mkIf cfg.enable {
    # Configure systemd resource control for the user service
    systemd.user.services.blackbox-terminal = {
      description = "Blackbox Terminal with optimized performance";
      serviceConfig = {
        # Set CPU scheduling priority (-20 is highest, 19 is lowest)
        Nice = mkIf cfg.highPriority "-10";
        # Set I/O priority
        IOSchedulingPriority = mkIf cfg.highPriority "0";
        # Memory limit
        MemoryLimit = "${toString cfg.memoryLimit}M";
      };
    };

    # Environment variables for GPU acceleration and performance
    environment.sessionVariables = mkIf cfg.gpuAcceleration {
      # Enable GPU acceleration
      BLACKBOX_ENABLE_GPU = "1";
      # Use hardware acceleration where possible
      BLACKBOX_FORCE_HARDWARE_ACCELERATION = "1";
      # Increase scroll buffer performance
      BLACKBOX_SCROLL_OPTIMIZATIONS = "1";
      # Disable animations if they're causing performance issues
      BLACKBOX_DISABLE_ANIMATIONS = "0";
    };

    # Install blackbox-terminal if not already included
    environment.systemPackages = with pkgs; [
      blackbox-terminal
    ];
    
    # Adjust system resource limits
    security.pam.loginLimits = [
      {
        domain = "*";
        item = "rtprio";
        type = "-";
        value = "99";
      }
      {
        domain = "*";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
    ];
  };
}
