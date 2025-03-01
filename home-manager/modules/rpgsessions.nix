{
  config,
  lib,
  pkgs,
  ...
}: let
  appName = "rpgsessions";
  css = ''
    @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");
    #TabsToolbar, #identity-box, #tabbrowser-tabs { display: none !important; }
    #nav-bar { visibility: collapse !important; }
    .tab-background[selected="true"] { background: #1a1a1a !important; }
  '';
in {
  programs.firefox = {
    enable = true;
    profiles.${appName} = {
      id = 1;
      settings = {
        "browser.sessionstore.resume_session_once" = false;
        "browser.sessionstore.resume_from_crash" = false;
        "browser.cache.disk.enable" = false;
        "webgl.enable-webgl2" = true;
        "dom.webnotifications.enabled" = true;
        "layout.css.prefers-color-scheme.content-override" = 0; # Dark mode
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = css;
    };
  };

  xdg.desktopEntries.${appName} = {
    name = "RPG Sessions";
    genericName = "Virtual Tabletop";
    exec = "${pkgs.firefox}/bin/firefox --class WebApp-${appName} -P ${appName} --no-remote https://rpgsessions.com";
    terminal = false;
    icon = "d20";
    categories = ["Game" "RolePlaying"];
    settings = {
      StartupWMClass = "WebApp-rpgsessions";
    };
  };

  # Optional: System-wide Firefox hardening
  programs.firefox.policies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    Preferences = {
      "network.cookie.lifetimePolicy" = lib.mkForce 0;
      "browser.tabs.firefox-view" = {
        Value = false;
        Status = "locked";
      };
    };
    ExtensionSettings = {
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        # uBlock Origin
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  };
}
