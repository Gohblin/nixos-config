{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.nixcord = {
    config = {
      transparent = true; # enables transparency (correct option name)
      frameless = true; # removes window frame
      useQuickCss = true; # enables the use of local CSS themes
    };

    # Option 1: Direct CSS content
    quickCss = ''

          /* Adjust transparency for glass theme */
      .theme-dark {
        --background-primary: rgba(30, 31, 34, 0.4) !important;
        --background-secondary: rgba(43, 45, 49, 0.35) !important;
        --background-secondary-alt: rgba(47, 49, 54, 0.35) !important;
        --background-tertiary: rgba(32, 34, 37, 0.4) !important;
        --channeltextarea-background: rgba(64, 68, 75, 0.35) !important;
        --background-floating: rgba(24, 25, 28, 0.45) !important;
      }

    '';

    # Option 2: Uncomment to read from a file instead
    # quickCss = builtins.readFile ./path/to/your/theme.css;
  };
}
