{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.editors;
in {
  options.editors = {
    enable = mkEnableOption "Editor configuration";

    neovim = {
      enable = mkEnableOption "Neovim configuration";
      withLSP = mkEnableOption "Configure Neovim with LSP support";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.neovim.enable [
      (pkgs.neovim.override {
        configure = {
          packages.myPlugins = with pkgs.vimPlugins; {
            start = [nvim-lspconfig] ++ optional cfg.neovim.withLSP nvim-lspconfig;
          };
          customRC = ''
            ${optionalString cfg.neovim.withLSP ''
              lua << EOF
              local lspconfig = require('lspconfig')
              ${concatStringsSep "\n" (mapAttrsToList (
                  name: langCfg:
                    optionalString (langCfg.enable && langCfg.lsp != null)
                    "lspconfig.${name}.setup{}"
                )
                config.programming.languages)}
              EOF
            ''}
          '';
        };
      })
    ];
  };
}
