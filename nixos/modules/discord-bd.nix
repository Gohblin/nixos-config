{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.discord-bd;

  # Download BetterDiscord
  betterdiscord = pkgs.fetchurl {
    url = "https://github.com/BetterDiscord/BetterDiscord/releases/download/v1.10.1/betterdiscord.asar";
    sha256 = "sha256-C6j2UXSl8Z6bcBAHWebXwxsSk64OxfVSjbE91mftNAQ=";
  };

  # Create a custom Discord package with BetterDiscord
  discord-with-bd = pkgs.discord.overrideAttrs (oldAttrs: {
    postInstall = ''
      ${oldAttrs.postInstall or ""}

      # Create BetterDiscord directories
      mkdir -p $out/opt/Discord/resources/app

      # Copy BetterDiscord
      cp ${betterdiscord} $out/opt/Discord/resources/app/betterdiscord.asar

      # Create BetterDiscord loader
      cat > $out/opt/Discord/resources/app/bd-loader.js << EOF
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

      # Patch Discord's index.js to load BetterDiscord
      MAIN_JS="$out/opt/Discord/resources/app/index.js"
      if [ -f "$MAIN_JS" ]; then
        echo "require('./bd-loader.js');" >> "$MAIN_JS"
      fi
    '';
  });
in {
  options.programs.discord-bd = {
    enable = mkEnableOption "Discord with BetterDiscord support";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [discord-with-bd];

    # Create necessary directories for all users
    system.activationScripts.betterdiscord = ''
      for dir in /home/*/.config/BetterDiscord; do
        if [ ! -d "$dir" ]; then
          mkdir -p "$dir/plugins" "$dir/themes"
          chown -R $(stat -c %U:%G "$(dirname "$dir")") "$dir"
        fi
      done
    '';
  };
}
