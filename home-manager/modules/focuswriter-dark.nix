{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeShellScriptBin "focuswriter-dark" ''
      export QT_QPA_PLATFORM=xcb
      export QT_STYLE_OVERRIDE=Fusion
      export QT_QPA_PLATFORMTHEME=qt5ct
      
      # Set up dictionary path
      export DICPATH="${hunspell}/share/hunspell"
      
      # Ensure multimedia support
      export LD_LIBRARY_PATH="${lib.makeLibraryPath [
        pipewire
        libpulseaudio
      ]}"
    
     exec ${focuswriter}/bin/focuswriter "$@"
  
    '')

    # Required dependencies
    hunspell
    hunspellDicts.en_US
    pipewire
    libsForQt5.qt5ct
    focuswriter
  ];

  # Configure qt5ct for dark theme
  home.file.".config/qt5ct/qt5ct.conf".text = ''
    [Appearance]
    custom_palette=true
    standard_dialogs=default
    style=Fusion

    [Interface]
    gui_effects=@Invalid()
    stylesheets=@Invalid()
    toolbutton_style=4

    [PaletteEditor]
    geometry=@ByteArray()

    [Palette]
    base_color=#2b2b2b
    highlight_color=#2b2b2b
    highlighted_text_color=#ffffff
    link_color=#0000ff
    link_visited_color=#ff00ff
    text_color=#ffffff
    window_color=#2b2b2b
    window_text_color=#ffffff
  '';

  # Add GNOME window rule to remove decorations
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      "focus-mode" = "click";
    };
    "org/gnome/mutter" = {
      "overlay-key" = "Super_L";
    };
    "org/gnome/shell/extensions/no-title-bar" = {
      "hide-window-titlebars" = true;
    };
  };

  # Add desktop entry
  home.file.".local/share/applications/focuswriter-dark.desktop".text = ''
    [Desktop Entry]
    Name=FocusWriter Dark
    Comment=Distraction-free writing environment with dark theme
    Exec=focuswriter-dark
    Icon=${pkgs.focuswriter}/share/icons/hicolor/128x128/apps/focuswriter.png
    Terminal=false
    Type=Application
    Categories=Office;WordProcessor;
    Keywords=Writing;Word;Text;
  '';
}
