# zsh.nix
{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = lib.mkForce {
      ll = "eza -al --icons";
      update = "sudo nixos-rebuild switch --flake .#nixos";
      gs = "git status";
      cat = "bat";
      reddit-tui = "nix run .#reddit-tui --impure";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "sudo"
        "terraform"
        "kubectl"
        "python"
        "npm"
      ];
      theme = ""; # Disable Oh My Zsh themes
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initExtra = ''
      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Source Powerlevel10k theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Load Pure style for Powerlevel10k
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/config/p10k-pure.zsh

      # Custom startup message
      echo "Welcome to ${config.home.username}'s shell"

      # Add custom paths
      export PATH="$HOME/.local/bin:$PATH"

      # Initialize FZF
      if [ -n "${pkgs.fzf}" ]; then
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        source ${pkgs.fzf}/share/fzf/completion.zsh
      fi
    '';
  };

  home.file.".p10k.zsh".text = ''
    # Generated Powerlevel10k Pure config
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline prompt_char)
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
    typeset -g POWERLEVEL9K_MODE=ascii
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=green
    typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=red
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=cyan
    typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=green
    typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=yellow
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=red
  '';

  home.packages = with pkgs; [
    eza
    bat
    ripgrep
    fzf
    nix-zsh-completions
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
