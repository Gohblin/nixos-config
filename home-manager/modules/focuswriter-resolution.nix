{ config, lib, pkgs, ... }:

{
  home.file.".config/focuswriter/focuswriter.conf".text = ''
    [General]
    AlwaysCenter=true
    BlockCursor=false
    Format=1
    WriteByteOrderMark=false

    [Window]
    Fullscreen=false
    Height=800
    Maximized=false
    Width=1200

    [View]
    FocusedText=true
    LargeSpacing=false
    PageMargins=35
    Paragraphs=false
    ScrollbarVisible=false
    SmartQuotes=true
    ToolbarVisible=false
    UseCustomFont=true
  '';

  home.sessionVariables = {
    # Fix scaling issues
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = "1";
    # Ensure proper DPI settings
    QT_FONT_DPI = "96";
  };
}
