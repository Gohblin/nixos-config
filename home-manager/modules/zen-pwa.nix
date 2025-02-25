{config, lib, pkgs, inputs, ...}:

with lib;

let
  cfg = config.programs.zen-pwa;
in {
  options.programs.zen-pwa = {
    enable = mkEnableOption "Zen Browser PWA support";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.firefoxpwa
    ];

    home.file = {
      ".librewolf/native-messaging-hosts/firefoxpwa.json".source = "${pkgs.firefoxpwa}/lib/mozilla/native-messaging-hosts/firefoxpwa.json";
      ".mozilla/native-messaging-hosts/firefoxpwa.json".source = "${pkgs.firefoxpwa}/lib/mozilla/native-messaging-hosts/firefoxpwa.json";
      
      ".librewolf/policies/policies.json".text = builtins.toJSON {
        policies = {
          ExtensionSettings = {
            "firefoxpwa@filips.si" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/firefoxpwa/latest.xpi";
            };
          };
        };
      };
    };
  };
}
