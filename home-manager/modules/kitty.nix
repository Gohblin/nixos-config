{
  config,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    settings = {
      # Font configuration
      font_family = "Free Mono";
      font_size = 8;
      adjust_line_height = "110%";

      # Window configuration
      window_padding_width = "10";
      background_opacity = "0.15";
      dynamic_background_opacity = "no";
      confirm_os_window_close = "0";

      hide_window_decorations = "yes";
      titlebar-only = "yes";

      # General settings
      enable_audio_bell = "yes";
      cursor_shape = "underline";
      cursor_blink_interval = "0.5";

      # Keep terminal open when process exits
      close_on_child_death = "no";
    };

    # Optional: Add your preferred color scheme here
    extraConfig = ''
      # Add any additional configuration here if needed
    '';
  };
}
