{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.webcord-vencord;

  # Fetch Gruvbox theme
  gruvbox-theme = pkgs.fetchFromGitHub {
    owner = "Entharia";
    repo = "gruvbox-discord";
    rev = "master";
    sha256 = "sha256-ItSfU5rQxxSeOfOqKDZSpzPCDFmgLxICAVKVjDD/Em4=";
  };

  # Create a custom WebCord package with Vencord and theme
  webcord-themed = pkgs.webcord-vencord.overrideAttrs (oldAttrs: {
    postInstall = ''
      ${oldAttrs.postInstall or ""}

      # Create Vencord theme directory
      mkdir -p $out/lib/node_modules/webcord/sources/app/VencordDesktop/themes

      # Install Gruvbox theme
      cp ${gruvbox-theme}/midnight.theme.css $out/lib/node_modules/webcord/sources/app/VencordDesktop/themes/midnight.theme.css

      # Create Vencord settings
      mkdir -p $out/lib/node_modules/webcord/sources/app/VencordDesktop/settings
      cat > $out/lib/node_modules/webcord/sources/app/VencordDesktop/settings/settings.json << EOF
      {
        "notifyAboutUpdates": true,
        "autoUpdate": true,
        "useQuickCss": true,
        "enableReactDevtools": true,
        "enabledThemes": ["midnight"],
        "themeLinks": [
          "https://raw.githubusercontent.com/Entharia/gruvbox-discord/master/midnight.theme.css"
        ]
      }
      EOF

      # Create QuickCSS
      cat > $out/lib/node_modules/webcord/sources/app/VencordDesktop/quickCss.css << EOF
      /* Gruvbox customizations */
      :root {
        /* Gruvbox Dark Colors */
        --bg: #282828;
        --bg0: #282828;
        --bg1: #3c3836;
        --bg2: #504945;
        --bg3: #665c54;
        --bg4: #7c6f64;

        --fg: #ebdbb2;
        --fg0: #fbf1c7;
        --fg1: #ebdbb2;
        --fg2: #d5c4a1;
        --fg3: #bdae93;
        --fg4: #a89984;

        --red: #fb4934;
        --green: #b8bb26;
        --yellow: #fabd2f;
        --blue: #83a598;
        --purple: #d3869b;
        --aqua: #8ec07c;
        --orange: #fe8019;

        /* Apply colors */
        --background-primary: var(--bg);
        --background-secondary: var(--bg1);
        --background-tertiary: var(--bg2);
        --channeltextarea-background: var(--bg1);
        --text-normal: var(--fg);
        --text-muted: var(--fg4);
        --header-primary: var(--fg0);
        --header-secondary: var(--fg2);
        --interactive-normal: var(--fg3);
        --interactive-hover: var(--fg1);
        --interactive-active: var(--fg0);
      }
      EOF
    '';
  });
in {
  options.programs.webcord-vencord = {
    enable = mkEnableOption "WebCord with Vencord support";
  };

  config = mkIf cfg.enable {
    home.packages = [
      webcord-themed
    ];
  };
}
