{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.nixPackageSearch;

  searchScript = pkgs.writeScriptBin "search" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    CACHE_DIR="$HOME/.cache/nix-package-search"
    mkdir -p "$CACHE_DIR"
    CACHE_FILE="$CACHE_DIR/packages.cache"

    exec 3>&1

    function do_update_cache() {
      echo "Updating package cache..." >&3
      ${pkgs.nix}/bin/nix search --json nixpkgs '.*' \
        | ${pkgs.jq}/bin/jq -r '
          to_entries[] |
          (.key | sub("legacyPackages\\.x86_64-linux\\.|legacyPackages\\.x86_64\\.|nixpkgs\\."; "")) as $cleankey |
          $cleankey + "|" + (.value.description // "No description available") + "|" + (.value.version // "unknown")
        ' > "$CACHE_FILE"
    }

    # Update cache if it doesn't exist or is older than 24 hours
    if [ ! -f "$CACHE_FILE" ] || [ $(find "$CACHE_FILE" -mtime +1 2>/dev/null || echo true) ]; then
      do_update_cache
    fi

    # Ensure cache file exists and has content
    if [ ! -s "$CACHE_FILE" ]; then
      do_update_cache
    fi

    TMP_REFRESH_SCRIPT=$(mktemp)
    echo "do_update_cache; cat $CACHE_FILE" > "$TMP_REFRESH_SCRIPT"
    chmod +x "$TMP_REFRESH_SCRIPT"

    # Main search interface using fzf
    selected=$(cat "$CACHE_FILE" | ${pkgs.fzf}/bin/fzf \
      --layout=reverse \
      --border=rounded \
      --preview '
        pkg=$(echo {} | cut -d"|" -f1)
        desc=$(echo {} | cut -d"|" -f2)
        ver=$(echo {} | cut -d"|" -f3)

        echo -e "\033[1;36m┌──────────────────────────────────────────\033[0m"
        printf "\033[1;36m│\033[0m \033[1;32m%-12s\033[0m %s\n" "Package:" "$pkg"
        printf "\033[1;36m│\033[0m \033[1;34m%-12s\033[0m %s\n" "Version:" "$ver"
        echo -e "\033[1;36m│\033[0m \033[1;33mDescription:\033[0m"
        echo -e "\033[1;36m│\033[0m $(echo "$desc" | fold -s -w 50 | sed '"'"'s/^/  /'"'"')"
        echo -e "\033[1;36m└──────────────────────────────────────────\033[0m"
      ' \
      --preview-window='right:60%:wrap' \
      --header=$'\033[1;35m╔═══ Nix Package Search ═══╗\n\033[1;35m║\033[0m CTRL-R: Refresh cache     \033[1;35m║\n\033[1;35m║\033[0m ENTER:  Show details     \033[1;35m║\n\033[1;35m╚════════════════════════╝\033[0m' \
      --bind "ctrl-r:execute($TMP_REFRESH_SCRIPT)" \
      --bind 'enter:execute(
        pkg=$(echo {} | cut -d"|" -f1);
        echo -e "\n\033[1;32m📦 Package Details for $pkg:\033[0m\n";
        ${pkgs.nix}/bin/nix eval --raw "nixpkgs#$pkg.meta" --apply builtins.toJSON 2>/dev/null |
        ${pkgs.jq}/bin/jq -C . |
        ${pkgs.bat}/bin/bat --style=plain --color=always
      )+abort')

    rm -f "$TMP_REFRESH_SCRIPT"

    if [ -n "$selected" ]; then
      pkg_name="$(echo "$selected" | cut -d"|" -f1)"
      echo -e "\n\033[1;33m📥 Installation Instructions:\033[0m"
      echo -e "\033[1;34m➤\033[0m nix-env -iA nixpkgs.$pkg_name"
      echo -e "\033[1;34m➤\033[0m Add to configuration.nix: environment.systemPackages = [ pkgs.$pkg_name ];"
    fi
  '';
in {
  options = {
    programs.nixPackageSearch = {
      enable = mkEnableOption "Nix package search utility";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      searchScript
      pkgs.fzf
      pkgs.jq
      pkgs.bat
    ];
  };
}
