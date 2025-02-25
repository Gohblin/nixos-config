{ config, inputs, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Text editors
    vim

    # System utilities
    git
    home-manager
    wget
    curl
    htop
    tree
    ripgrep
    fd
    file
    unzip
    xclip

    # System monitoring
    btop
    dconf2nix
    iotop
    lsof
    atuin
    gnomeExtensions.pop-shell
    gnomeExtensions.transparent-top-bar-adjustable-transparency
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.coverflow-alt-tab
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.desktop-cube
    gnomeExtensions.fly-pie
    gnomeExtensions.caffeine
    gnomeExtensions.dynamic-panel
    gnome-extension-manager

    # Network tools
    dig
    whois
    nmap
    tcpdump
    netcat

    # Development tools
    gcc
    gnumake
    python3
    
    # Terminal utilities
    tmux
    fzf
    bat
    jq
    inputs.zen-browser.packages."${system}".default

    # Archive tools
    zip
    unzip
    p7zip

    # System information
    neofetch
    inxi
  ];

  # Enable bash completion for all programs
  programs.bash.completion.enable = true;

}
