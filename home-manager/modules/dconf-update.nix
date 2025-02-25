{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.programs.dconf-update;
  updateScript = pkgs.writeShellScriptBin "update-dconf" ''
    set -e
    DCONF_INI="/tmp/dconf.ini"
    DCONF_NIX="/tmp/dconf.nix"
    TARGET="${config.home.homeDirectory}/nixos-config/home-manager/modules/dconf.nix"

    echo "Dumping current dconf settings..."
    ${pkgs.dconf}/bin/dconf dump / > "$DCONF_INI"

    echo "Converting to Nix..."
    ${pkgs.dconf2nix}/bin/dconf2nix --input "$DCONF_INI" --output "$DCONF_NIX"

    echo "Updating dconf.nix..."
    cp "$DCONF_NIX" "$TARGET"

    echo "Cleaning up..."
    rm "$DCONF_INI" "$DCONF_NIX"

    echo "Done! Your dconf settings have been updated in dconf.nix"
    echo "Remember to rebuild your system to apply the changes"
  '';
in {
  options.programs.dconf-update = {
    enable = mkEnableOption "dconf settings update command";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.dconf
      pkgs.dconf2nix
      updateScript
    ];
  };
}
