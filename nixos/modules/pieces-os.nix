# ./modules/pieces-os.nix
{ config, pkgs, ... }:

{
  systemd.services.pieces-os = {
    # Use the full path to the Snap binary
    serviceConfig.ExecStart = "/snap/bin/pieces-os --no-debug";
    
    # Ensure the service restarts when the config changes
    restartTriggers = [ config.systemd.services.pieces-os.serviceConfig.ExecStart ];
  };

  # Optional: Force "pieces-for-devs" to use debug mode if needed
  systemd.services.pieces-for-devs = {
    serviceConfig.ExecStart = "/snap/bin/pieces-for-devs --debug";
  };
}
