{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    enableManpages = true;

    # Plugin sources configuration
    pluginSources = {
      # Use specific plugin sources if needed
      markdown-preview-nvim.source = "iamcco/markdown-preview.nvim";
      # Add other plugin sources as needed
    };

    vim = {
      # Basic editor settings for writing
      options = {
        number = false;
        relativenumber = false;
        wrap = true;
        linebreak = true;
        scrolloff = 8;
        conceallevel = 2;
        spelllang = "en_us";
        spell = true;  # Enable spellcheck
      };

      # Core plugins for writing
      startPlugins = [
        "zen-mode-nvim"
        "twilight-nvim"
        "nvim-autopairs"
        "nvim-surround"
        "lualine-nvim"
        "markdown-preview-nvim"
      ];

      # Theme setup
      colorschemes = {
        enable = true;
        name = "rose-pine";
        transparent = true;
      };

      # Leader key configuration
      globals.mapleader = " ";

      # Keybindings
      maps = {
        normal = {
          "<leader>z" = {
            action = ":ZenMode<CR>";
            desc = "Toggle Zen Mode";
          };
          "<leader>w" = {
            action = ":w<CR>";
            desc = "Save file";
          };
          "<leader>mp" = {
            action = ":MarkdownPreview<CR>";
            desc = "Preview Markdown";
          };
        };
      };

      # Plugin configurations in Lua
      luaConfigRC = ''
        -- Zen Mode setup
        require("zen-mode").setup({
          window = {
            width = 90,
            options = {
              signcolumn = "no",
              number = false,
              relativenumber = false,
            }
          },
          plugins = {
            options = {
              enabled = true,
              ruler = false,
              showcmd = false,
            },
            twilight = { enabled = true },
            gitsigns = { enabled = false },
          }
        })

        -- Twilight setup for focus mode
        require("twilight").setup({
          dimming = {
            alpha = 0.25,
            color = { "Normal", "#ffffff" },
            inactive = true,
          },
        })

        -- Minimal status line
        require("lualine").setup({
          options = {
            theme = "rose-pine",
            component_separators = "|",
            section_separators = "",
          },
          sections = {
            lualine_a = {"mode"},
            lualine_b = {},
            lualine_c = {"filename"},
            lualine_x = {},
            lualine_y = {"progress"},
            lualine_z = {},
          }
        })
      '';
    };
  };
}
