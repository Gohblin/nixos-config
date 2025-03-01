# configuration.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Import nvf module
    inputs.nvf.nixosModules.default
  ];

  programs.nvf = {
    enable = true;

    # Enable built-in documentation
    enableManpages = true;

    # Core editor configuration
    vim = {
      # Basic editor settings
      options = {
        number = false; # Disable line numbers for distraction-free writing
        relativenumber = false;
        wrap = true; # Enable soft wrapping
        linebreak = true; # Break lines at word boundaries
        scrolloff = 8; # Keep 8 lines visible above/below cursor
        conceallevel = 2; # Hide markdown syntax
      };

      # Essential plugins for writing
      startPlugins = [
        "zen-mode-nvim" # Distraction-free writing mode
        "twilight-nvim" # Dim inactive code
        "nvim-autopairs" # Auto-close pairs
        "nvim-surround" # Surround text objects
        "lualine-nvim" # Minimal status line
        "markdown-preview-nvim" # Markdown preview
      ];

      # Theme configuration
      colorschemes = {
        enable = true;
        name = "rose-pine";
        transparent = true;
      };

      # Rest of the configuration remains the same as above...
    };
  };
}
