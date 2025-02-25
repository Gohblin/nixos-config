{ config, lib, pkgs, ... }:

{
  dconf.settings = {
    "com/raggesilver/BlackBox" = {
      command-as-login-shell = true;
      custom-shell-command = "";
      font = "Free Mono 8";
      theme-dark = "";
      window-height = 600;
      window-width = 800;
      terminal-padding = with lib.hm.gvariant; mkTuple
        [
          (mkUint32 10)
          (mkUint32 10)
          (mkUint32 10)
          (mkUint32 10)
        ];
      window-opacity = with lib.hm.gvariant; mkDouble 0.9;  # 0.1 = 90% solid, 10% transparent
    };
  };
}
