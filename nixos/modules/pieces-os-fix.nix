{
  config,
  pkgs,
  ...
}: {
  system.activationScripts.pieces-os-fonts = {
    text = ''
      if [ ! -d /etc/fonts ]; then
        mkdir -p /etc/fonts
        ln -sf ${pkgs.fontconfig.out}/etc/fonts/* /etc/fonts/
      fi
    '';
    deps = [];
  };
}
