{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    dconf.settings = {
      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Super>q"];
      };
    };
  };
}
