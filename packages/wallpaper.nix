# Save this as wallpaper.nix
{ pkgs ? import <nixpkgs> {} }:

let
  nixWallpaperFlake = builtins.getFlake "github:lunik1/nix-wallpaper";
  baseWallpaper = nixWallpaperFlake.packages.${pkgs.system}.default;

  customWallpaper = baseWallpaper.override {
    preset = "gruvbox-dark";
    logoSize = 44;
  };
in
pkgs.stdenv.mkDerivation {
  name = "custom-nix-wallpaper";
  
  src = pkgs.emptyDirectory;
  
  buildInputs = [ pkgs.imagemagick customWallpaper ];
  
  dontUnpack = true;
  
  buildPhase = ''
    mkdir -p wallpapers
    cp ${customWallpaper}/share/wallpapers/nixos-wallpaper.png wallpapers/

    # Extract background color from the original
    BG_COLOR=$(magick wallpapers/nixos-wallpaper.png -format "%[pixel:p{0,0}]" info:)
    
    # Create a new image with the background color
    magick -size 3840x2160 xc:"$BG_COLOR" wallpapers/base.png
    
    # Composite the logo onto the background with center gravity and offset to the left
    magick composite \
      -gravity center \
      -geometry -900+0 \
      wallpapers/nixos-wallpaper.png \
      wallpapers/base.png \
      wallpapers/modified-wallpaper.png
    
    mkdir -p $out/share/wallpapers
    cp wallpapers/modified-wallpaper.png $out/share/wallpapers/nixos-wallpaper.png
  '';

  dontInstall = true;
}
