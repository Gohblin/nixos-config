{
  config,
  lib,
  pkgs,
  ...
}: 
with lib;
let
  cfg = config.programs.discord-vencord;
in {
  options.programs.discord-vencord = {
    enable = mkEnableOption "Discord with Vencord support";
  };

  config = mkIf cfg.enable {
    home.packages = [ 
      pkgs.discord
      pkgs.vencord-installer
    ];

    # Run Vencord installer on activation
    home.activation.installVencord = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "$HOME/.config/discord" ]; then
        $DRY_RUN_CMD ${pkgs.vencord-installer}/bin/vencord-installer --install
      fi
    '';
  };
}
