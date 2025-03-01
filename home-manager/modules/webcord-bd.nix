{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.webcord-bd;

  # Download BetterDiscord
  betterdiscord = pkgs.fetchurl {
    url = "https://github.com/BetterDiscord/BetterDiscord/releases/download/v1.10.1/betterdiscord.asar";
    sha256 = "sha256-C6j2UXSl8Z6bcBAHWebXwxsSk64OxfVSjbE91mftNAQ=";
  };

  # Create a custom derivation for WebCord with BetterDiscord support
  webcord-with-bd = pkgs.webcord.overrideAttrs (oldAttrs: {
    # Enable DevTools which is required for BetterDiscord
    postInstall = ''
      # Create WebCord config
      mkdir -p $out/etc/webcord
      cat > $out/etc/webcord/config.json << EOF
      {
        "DANGEROUS_ENABLE_DEVTOOLS": true,
        "SKIP_HOST_UPDATE": true
      }
      EOF

      # Create BetterDiscord directories and files
      mkdir -p $out/lib/webcord/resources/app
      cp ${betterdiscord} $out/lib/webcord/resources/app/betterdiscord.asar

      # Create BetterDiscord loader
      cat > $out/lib/webcord/resources/app/bd-loader.js << EOF
      const { app } = require('electron');
      const path = require('path');
      const asar = require('asar');

      // Extract BetterDiscord
      const asarPath = path.join(__dirname, 'betterdiscord.asar');
      const bdPath = path.join(app.getPath('userData'), 'betterdiscord');

      app.on('ready', () => {
        // Extract BetterDiscord if not already extracted
        if (!require('fs').existsSync(bdPath)) {
          asar.extractAll(asarPath, bdPath);
        }

        // Load BetterDiscord
        require(path.join(bdPath, 'betterdiscord.js')).initialize();
      });
      EOF

      # Patch WebCord's main.js to load BetterDiscord
      MAIN_JS="$out/lib/webcord/resources/app/main.js"
      if [ -f "$MAIN_JS" ]; then
        echo "require('./bd-loader.js');" >> "$MAIN_JS"
      fi
    '';
  });

  # Create a wrapper script for WebCord
  webcord-wrapper = pkgs.writeScriptBin "webcord" ''
    #!${pkgs.bash}/bin/bash
    export WEBCORD_CONFIG_PATH="$HOME/.config/WebCord"
    mkdir -p "$WEBCORD_CONFIG_PATH"
    mkdir -p "$WEBCORD_CONFIG_PATH/plugins"
    mkdir -p "$WEBCORD_CONFIG_PATH/themes"

    # Create WebCord config if it doesn't exist
    if [ ! -f "$WEBCORD_CONFIG_PATH/config.json" ]; then
      cat > "$WEBCORD_CONFIG_PATH/config.json" << EOF
    {
      "DANGEROUS_ENABLE_DEVTOOLS": true,
      "SKIP_HOST_UPDATE": true
    }
    EOF
    fi

    exec ${webcord-with-bd}/bin/webcord "$@"
  '';
in {
  options.programs.webcord-bd = {
    enable = mkEnableOption "WebCord with BetterDiscord support";
  };

  config = mkIf cfg.enable {
    # Add to your home-manager configuration
    home.packages = [
      webcord-wrapper # Use our wrapper instead of webcord directly
    ];

    # Create necessary directories
    xdg.configFile = {
      "WebCord/.keep".text = "";
      "WebCord/plugins/.keep".text = "";
      "WebCord/themes/.keep".text = "";
    };
  };
}
