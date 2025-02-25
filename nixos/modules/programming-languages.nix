{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programming;
in {
  options.programming = {
    enable = mkEnableOption "Programming languages and tools";
    
    languages = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "Enable this programming language";
          packages = mkOption {
            type = types.listOf types.package;
            default = [];
            description = "Packages associated with this language";
          };
          lsp = mkOption {
            type = types.nullOr types.package;
            default = null;
            description = "Language server package for this language";
          };
        };
      });
      default = {};
      description = "Programming languages configuration";
    };
  };

  config = mkIf cfg.enable {
    # This module now only defines options and doesn't set any configuration
    # You can access the enabled languages, their packages, and LSPs elsewhere in your config
  };
}

