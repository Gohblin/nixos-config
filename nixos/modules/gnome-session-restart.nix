{ config, lib, pkgs, ... }:

let
  userName = builtins.head (builtins.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users));
in {
  options = {
    services.gnomeSessionRestart = {
      enable = lib.mkEnableOption "GNOME session restart with automatic login";
      password = lib.mkOption {
        type = lib.types.str;
        description = "User password for automatic login (warning: stored in nix store)";
      };
    };
  };

  config = lib.mkIf config.services.gnomeSessionRestart.enable {
    environment.systemPackages = [
      (pkgs.writeScriptBin "restart-gnome-session" ''
        #!${pkgs.runtimeShell}
        
        # Restart GNOME session
        dbus-send --session --type=method_call \
          --dest=org.gnome.SessionManager \
          /org/gnome/SessionManager \
          org.gnome.SessionManager.Logout \
          uint32:0
        
        # Start the auto-login service
        systemctl start gnome-autologin.service
      '')
      pkgs.xdotool
    ];

    systemd.services.gnome-autologin = {
      description = "Automatic login for GNOME session restart";
      script = ''
        # Wait for the login screen to appear
        sleep 5
        
        # Type the password and press Enter
        ${pkgs.xdotool}/bin/xdotool type ${config.services.gnomeSessionRestart.password}
        ${pkgs.xdotool}/bin/xdotool key Return
      '';
      serviceConfig = {
        Type = "oneshot";
        User = userName;
        Environment = "DISPLAY=:0";
      };
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.gnome.SessionManager.Logout" &&
            subject.user == "${userName}") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}

