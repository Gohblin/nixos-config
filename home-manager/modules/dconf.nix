# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "com/ftpix/transparentbar" = {
      dark-full-screen = false;
      transparency = 0;
    };

    "com/mattjakeman/ExtensionManager" = {
      height = 788;
      is-maximized = false;
      last-used-version = "0.5.1";
      show-unsupported = true;
      width = 1250;
    };

    "com/raggesilver/BlackBox" = {
      cursor-shape = mkUint32 2;
      easy-copy-paste = true;
      font = "DejaVu Sans Mono 8";
      opacity = mkUint32 65;
      pretty = true;
      show-headerbar = false;
      show-scrollbars = false;
      style-preference = mkUint32 2;
      terminal-bell = false;
      terminal-padding = mkTuple [(mkUint32 20) (mkUint32 20) (mkUint32 20) (mkUint32 20)];
      use-custom-command = true;
      window-height = mkUint32 788;
      window-width = mkUint32 1250;
    };

    "org/gnome/Console" = {
      last-window-maximised = false;
      last-window-size = mkTuple [627 396];
    };

    "org/gnome/Extensions" = {
      window-height = 804;
      window-width = 1266;
    };

    "org/gnome/Geary" = {
      migrated-config = true;
      window-height = 325;
      window-width = 1076;
    };

    "org/gnome/Music" = {
      window-maximized = true;
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = true;
      window-size = mkTuple [768 600];
    };

    "org/gnome/clocks/state/window" = {
      maximized = false;
      panel-id = "world";
      size = mkTuple [1266 804];
    };

    "org/gnome/control-center" = {
      last-panel = "background";
      window-state = mkTuple [1266 804 false];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = ["Utilities" "YaST" "Pardus"];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = ["X-Pardus-Apps"];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = ["org.freedesktop.GnomeAbrt.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.font-viewer.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop"];
      categories = ["X-GNOME-Utilities"];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = ["X-SuSE-YaST"];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/joshua/.local/share/backgrounds/2025-02-23-00-19-47-nixos-wallpaper.png";
      picture-uri-dark = "file:///home/joshua/.local/share/backgrounds/2025-02-23-00-19-47-nixos-wallpaper.png";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/input-sources" = {
      sources = [(mkTuple ["xkb" "us"])];
      xkb-options = ["terminate:ctrl_alt_bksp"];
    };

    "org/gnome/desktop/interface" = {
      accent-color = "slate";
      clock-format = "12h";
      color-scheme = "prefer-dark";
      enable-animations = true;
      scaling-factor = 2;
      text-scaling-factor = 1.0;
    };

    "org/gnome/desktop/monitor/primary" = {
      display-name = "Built-in display";
      height = 1504;
      width = 2256;
    };

    "org/gnome/desktop/notifications" = {
      application-children = ["org-gnome-console" "gnome-power-panel" "zen" "com-mattjakeman-extensionmanager" "discord"];
    };

    "org/gnome/desktop/notifications/application/com-mattjakeman-extensionmanager" = {
      application-id = "com.mattjakeman.ExtensionManager.desktop";
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/zen" = {
      application-id = "zen.desktop";
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/joshua/.local/share/backgrounds/2025-02-23-00-19-47-nixos-wallpaper.png";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
    };

    "org/gnome/desktop/wm/preferences" = {
      focus-mode = "click";
    };

    "org/gnome/epiphany" = {
      ask-for-default = false;
    };

    "org/gnome/epiphany/state" = {
      is-maximized = true;
      window-size = mkTuple [1290 828];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/mutter" = {
      edge-tiling = false;
      experimental-features = ["scale-monitor-framebuffer" "scale-monitor-framebuffer"];
      overlay-key = "Super_L";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [627 804];
      initial-size-file-chooser = mkTuple [890 550];
      maximized = false;
    };

    "org/gnome/portal/filechooser/gnome-background-panel" = {
      last-folder-path = "/home/joshua/nixos-config/result/share/wallpapers";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-schedule-automatic = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = true;
    };

    "org/gnome/shell" = {
      command-history = ["r"];
      disable-user-extensions = false;
      disabled-extensions = ["places-menu@gnome-shell-extensions.gcampax.github.com" "dash-to-panel@jderose9.github.com" "window-title-is-back@fthx" "gtktitlebar@velitasali.github.io" "transparent-window-moving@noobsai.github.com" "rounded-window-corners@fxgn" "desktop-cube@schneegans.github.com" "dynamic-panel@velhlkj.com"];
      enabled-extensions = ["blur-my-shell@aunetx" "pop-shell@system76.com" "dash-to-dock@micxgx.gmail.com" "flypie@schneegans.github.com" "CoverflowAltTab@palatis.blogspot.com" "compiz-windows-effect@hermes83.github.com" "caffeine@patapon.info" "transparent-top-bar@ftpix.com"];
      favorite-apps = ["org.gnome.Nautilus.desktop" "zen.desktop"];
      last-selected-power-profile = "performance";
      welcome-dialog-last-shown-version = "47.2";
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 0.6;
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 0.6;
      pipeline = "pipeline_default_rounded";
      sigma = 0;
      static-blur = false;
      style-dash-to-dock = 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
      brightness = 0.6;
      pipeline = "pipeline_default";
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = 0.6;
      sigma = 30;
    };

    "org/gnome/shell/extensions/caffeine" = {
      countdown-timer = 0;
      indicator-position-max = 1;
      restore-state = true;
      toggle-state = true;
      user-enabled = true;
    };

    "org/gnome/shell/extensions/com/github/hermes83/compiz-windows-effect" = {
      friction = 10.0;
      mass = 40.0;
      resize-effect = true;
      speedup-factor-divider = 14.9;
      spring-k = 10.0;
    };

    "org/gnome/shell/extensions/coverflowalttab" = {
      current-workspace-only = "all";
      switcher-background-color = mkTuple [1.0 1.0 1.0];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      background-opacity = 0.8;
      dash-max-icon-size = 48;
      dock-position = "BOTTOM";
      height-fraction = 0.9;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "eDP-1";
    };

    "org/gnome/shell/extensions/dynamic-panel" = {
      auto-width = false;
      background-mode = 0;
      detection-mode = 1;
      transparent = 40;
      transparent-menus-keep-alpha = true;
    };

    "org/gnome/shell/extensions/flypie" = {
      active-stack-child = "settings-page";
      child-color-mode-hover = "auto";
      menu-configuration = "[{\"name\":\"Example Menu\",\"icon\":\"flypie-symbolic-#46a\",\"shortcut\":\"<Primary>space\",\"centered\":false,\"id\":0,\"children\":[{\"name\":\"Sound\",\"icon\":\"flypie-multimedia-symbolic-#c86\",\"children\":[{\"name\":\"Mute\",\"icon\":\"flypie-multimedia-mute-symbolic-#853\",\"type\":\"Shortcut\",\"data\":\"AudioMute\",\"angle\":-1},{\"name\":\"Play / Pause\",\"icon\":\"flypie-multimedia-playpause-symbolic-#853\",\"type\":\"Shortcut\",\"data\":\"AudioPlay\",\"angle\":-1},{\"name\":\"Next Title\",\"icon\":\"flypie-multimedia-next-symbolic-#853\",\"type\":\"Shortcut\",\"data\":\"AudioNext\",\"angle\":90},{\"name\":\"Previous Title\",\"icon\":\"flypie-multimedia-previous-symbolic-#853\",\"type\":\"Shortcut\",\"data\":\"AudioPrev\",\"angle\":270}],\"type\":\"CustomMenu\",\"data\":{},\"angle\":-1},{\"name\":\"Favorites\",\"icon\":\"flypie-menu-favorites-symbolic-#da3\",\"type\":\"Favorites\",\"data\":{},\"angle\":-1},{\"name\":\"Next Workspace\",\"icon\":\"flypie-go-right-symbolic-#6b5\",\"type\":\"Shortcut\",\"data\":{\"shortcut\":\"<Control><Alt>Right\"},\"angle\":-1},{\"name\":\"Maximize Window\",\"icon\":\"flypie-window-maximize-symbolic-#b68\",\"type\":\"Shortcut\",\"data\":\"<Alt>F10\",\"angle\":-1},{\"name\":\"Fly-Pie Settings\",\"icon\":\"flypie-menu-system-symbolic-#3ab\",\"type\":\"Command\",\"data\":\"gnome-extensions prefs flypie@schneegans.github.com\",\"angle\":-1},{\"name\":\"Close Window\",\"icon\":\"flypie-window-close-symbolic-#a33\",\"type\":\"Shortcut\",\"data\":\"<Alt>F4\",\"angle\":-1},{\"name\":\"Previous Workspace\",\"icon\":\"flypie-go-left-symbolic-#6b5\",\"type\":\"Shortcut\",\"data\":{\"shortcut\":\"<Control><Alt>Left\"},\"angle\":-1},{\"name\":\"Running Apps\",\"icon\":\"flypie-menu-running-apps-symbolic-#65a\",\"type\":\"RunningApps\",\"data\":{\"activeWorkspaceOnly\":false,\"appGrouping\":true,\"hoverPeeking\":true,\"nameRegex\":\"\"},\"angle\":-1}],\"type\":\"CustomMenu\",\"data\":{}}]";
      stats-settings-opened = mkUint32 1;
    };

    "org/gnome/shell/extensions/no-title-bar" = {
      hide-window-titlebars = true;
    };

    "org/gnome/shell/extensions/pop-shell" = {
      gap-inner = mkUint32 5;
      gap-outer = mkUint32 5;
      tile-by-default = true;
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };

    "org/gtk/settings/color-chooser" = {
      custom-colors = [(mkTuple [0.4 0.4 0.4 1.0])];
      selected-color = mkTuple [true 1.0 1.0 1.0 1.0];
    };

    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 157;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [29 32];
      window-size = mkTuple [1231 781];
    };
  };
}
