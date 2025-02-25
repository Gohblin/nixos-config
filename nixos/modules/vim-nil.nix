# vim-nil.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.vim-nil;
in {
  options.programs.vim-nil = {
    enable = mkEnableOption "Vim configuration with Nix Language Server support";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vim
      nil
      nixpkgs-fmt
      vimPlugins.vim-lsp
      vimPlugins.vim-nix
    ];

    environment.variables.EDITOR = "vim";

    programs.vim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-lsp
        vim-nix
      ];
      extraConfig = ''
        " Enable LSP for Nix
        lua require('lspconfig').nil_ls.setup{}

        " Set up LSP keybindings
        nnoremap <silent> gd :LspDefinition<CR>
        nnoremap <silent> K :LspHover<CR>
        nnoremap <silent> <leader>rn :LspRename<CR>

        " Basic Vim settings
        set number
        set relativenumber
        set shiftwidth=2
        set expandtab
      '';
    };
  };
}

