{ config, pkgs, ... }:

{
  # GNOME autologin workaround
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
