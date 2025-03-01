{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.minecraft-firewall;
in {
  options.services.minecraft-firewall = {
    enable = mkEnableOption "Minecraft server firewall configuration";

    port = mkOption {
      type = types.port;
      default = 25565;
      description = "The port number for the Minecraft server";
    };

    useTailscale = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to configure firewall for Tailscale";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [cfg.port];
      trustedInterfaces = mkIf cfg.useTailscale ["tailscale0"];
    };

    services.tailscale.enable = cfg.useTailscale;
  };
}
