# clipboard-copy.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.clipboard-copy;
  copyScript = pkgs.writeShellScriptBin "cp2cb" ''
    if [ -z "$1" ]; then
      echo "Usage: cp2cb <file>"
      exit 1
    fi
    
    if [ -n "$WAYLAND_DISPLAY" ]; then
      ${pkgs.wl-clipboard}/bin/wl-copy < "$1"
    else
      ${pkgs.xclip}/bin/xclip -selection clipboard < "$1"
    fi
  '';
in {
  options.custom.clipboard-copy = {
    enable = mkEnableOption "Enable clipboard file copy utility";
  };

  config = mkIf cfg.enable {
    home.packages = [ 
      copyScript
      pkgs.xclip
      pkgs.wl-clipboard
    ];
  };
}

