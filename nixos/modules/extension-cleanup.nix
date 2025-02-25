{ pkgs, ... }:

let
  clean-extensions = pkgs.writeScriptBin "clean-extensions" ''
    #!/usr/bin/env bash
    for uuid in $(dconf list /org/gnome/shell/extensions/); do
      if [ ! -d "$HOME/.local/share/gnome-shell/extensions/''${uuid%/}" ] && \
         [ ! -d "/run/current-system/sw/share/gnome-shell/extensions/''${uuid%/}" ]; then
        echo "Resetting orphaned extension: ''${uuid%/}"
        dconf reset -f /org/gnome/shell/extensions/''${uuid}
      fi
    done
  '';
in {
  environment.systemPackages = [ clean-extensions ];
}

