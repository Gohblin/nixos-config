{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Text editors and IDEs
    vim

    # Terminal utilities
    tmux
    fzf
    bat
    jq
    atuin
    tui-journal
    tuisky
    inputs.zen-browser.packages."${system}".default

    # System utilities
    wget
    curl
    htop
    tree
    file
    xclip

    # File and search tools
    ripgrep
    fd

    # Archive tools
    zip
    unzip
    p7zip

    # System monitoring and information
    btop
    iotop
    lsof
    neofetch
    inxi

    # Network tools
    dig
    whois
    nmap
    tcpdump
    netcat

    # Development tools
    git
    gcc
    gnumake
    python3

    # System management
    home-manager
    dconf2nix
  ];
}
