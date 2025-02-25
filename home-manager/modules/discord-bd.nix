{
  config,
  lib,
  pkgs,
  ...
}: 
with lib;
let
  cfg = config.programs.discord-bd;
in {
  options.programs.discord-bd = {
    enable = mkEnableOption "Discord with BetterDiscord support";
  };

  config = mkIf cfg.enable {
    home.packages = [ 
      pkgs.discord
      pkgs.betterdiscordctl
      pkgs.curl
    ];

    # Create necessary directories
    xdg.configFile = {
      "BetterDiscord/plugins/.keep".text = "";
      "BetterDiscord/themes/.keep".text = "";
    };

    # Run betterdiscordctl on activation
    home.activation.installBetterDiscord = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="${pkgs.curl}/bin:$PATH"
      $DRY_RUN_CMD ${pkgs.betterdiscordctl}/bin/betterdiscordctl install
    '';
  };
}
