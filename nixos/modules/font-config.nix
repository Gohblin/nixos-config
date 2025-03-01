{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    myFontConfig = {
      enable = lib.mkEnableOption "Enable custom font configuration";
    };
  };

  config = lib.mkIf config.myFontConfig.enable {
    fonts = {
      enableDefaultFonts = true;
      fontconfig = {
        antialias = true;
        hinting = {
          enable = true;
          style = "slight";
        };
        subpixel = {
          rgba = "rgb";
          lcdfilter = "default";
        };
      };
      fonts = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
      ];
    };

    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];
  };
}
