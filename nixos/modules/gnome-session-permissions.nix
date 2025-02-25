{ config, lib, ... }:

let
  userName = builtins.head (builtins.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users));
in {
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.gnome.SessionManager.Logout" ||
           action.id == "org.freedesktop.systemd1.manage-units") &&
          subject.user == "${userName}") {
        return polkit.Result.YES;
      }
    });
  '';

  security.sudo.extraRules = [{
    commands = [
      { command = "/run/current-system/sw/bin/systemctl start gdm-autologin-once.service"; options = ["NOPASSWD"]; }
    ];
    users = [ "${userName}" ];
  }];
}

