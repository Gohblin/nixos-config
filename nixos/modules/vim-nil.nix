{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.vim-nil;
in {
  options.programs.vim-nil = {
    enable = mkEnableOption "Vim configuration with Nix Language Server support and autocompletion";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (vim_configurable.customize {
        name = "vim";
        vimrcConfig.packages.myVimPackage = {
          start = with pkgs.vimPlugins; [
            vim-nix
            vim-lsp
            asyncomplete-vim
            asyncomplete-lsp-vim
          ];
        };
        vimrcConfig.customRC = ''
          " Enable LSP for Nix
          if executable('nil')
            au User lsp_setup call lsp#register_server({
                \ 'name': 'nil',
                \ 'cmd': {server_info->['nil']},
                \ 'whitelist': ['nix'],
                \ })
          endif

          " Enable autocompletion
          let g:asyncomplete_auto_popup = 1
          let g:asyncomplete_auto_completeopt = 0
          set completeopt=menuone,noinsert,noselect,preview

          " Set up LSP keybindings
          nnoremap <silent> gd :LspDefinition<CR>
          nnoremap <silent> K :LspHover<CR>
          nnoremap <silent> <leader>rn :LspRename<CR>
          inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
          inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
          inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

          " Basic Vim settings
          set number
          set relativenumber
          set shiftwidth=2
          set expandtab
        '';
      })
      nil
      nixpkgs-fmt
    ];

    environment.variables.EDITOR = "vim";
  };
}

