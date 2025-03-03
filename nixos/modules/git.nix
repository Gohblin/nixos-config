# modules/git.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    git = {
      enable = lib.mkEnableOption "Git configuration management";
      userName = lib.mkOption {
        type = lib.types.str;
        default = "Gohblin";
        description = "Git commit username";
      };
      userEmail = lib.mkOption {
        type = lib.types.str;
        default = "literategoblin@gmail.com";
        description = "Git commit email";
      };
    };
  };

  config = lib.mkIf config.git.enable {
    # System-wide Git packages
    environment.systemPackages = with pkgs; [
      gitFull
      git-crypt
      gh
    ];

    # Global Git configuration (applies to all users)
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
          whitespace = "trailing-space,space-before-tab";
        };
        pull.rebase = false;
        color.ui = true;
      };
    };

    # User-specific Git config via Home Manager
    home-manager.users."joshua" = {
      # Your actual system username here
      programs.git = {
        enable = true;
        userName = config.git.userName; # Your Git username "Gohblin"
        userEmail = config.git.userEmail;
        aliases = {
          st = "status";
          ci = "commit";
          co = "checkout";
          br = "branch";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          visual = "!gitk";
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        };
        extraConfig = {
          credential.helper = "store --file ~/.git-credentials";
          include.path = "~/.gitconfig.local";
        };
      };
    };
  };
}
