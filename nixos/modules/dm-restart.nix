{
  config,
  lib,
  pkgs,
  ...
}: let
  users = lib.filterAttrs (_: user: user.isNormalUser) config.users.users;
  userName =
    if users == {}
    then throw "No normal user configured"
    else lib.head (lib.attrNames users);
in {
  config = {
    services.dbus.packages = [pkgs.gnome-session];

    environment.systemPackages = [
      (pkgs.writeScriptBin "restart-gnome-session" ''
        #!${pkgs.runtimeShell}
        dbus-send --session --type=method_call \
          --dest=org.gnome.SessionManager \
          /org/gnome/SessionManager \
          org.gnome.SessionManager.Logout \
          uint32:1
      '')
    ];

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
