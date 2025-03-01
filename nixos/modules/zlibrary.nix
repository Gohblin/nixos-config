{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.zlibrary;

  # Create the setup script
  zlibrary-script = pkgs.writeScriptBin "zlibrary" ''
    #!${pkgs.bash}/bin/bash

    # Check if container exists
    if ! ${pkgs.distrobox}/bin/distrobox list | grep -q "${cfg.container}"; then
      echo "Creating Z-Library container..."
      ${pkgs.distrobox}/bin/distrobox create --name ${cfg.container} --image ${cfg.baseImage}

      # Install dependencies inside container
      echo "Installing dependencies..."
      ${pkgs.distrobox}/bin/distrobox enter ${cfg.container} -- bash -c '
        # Add Chrome repository
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        sudo sh -c "echo deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main > /etc/apt/sources.list.d/google.list"

        # Update and install dependencies
        sudo apt-get update
        sudo apt-get install -y \
          google-chrome-stable \
          ca-certificates \
          apt-transport-https \
          gvfs \
          gvfs-common \
          gvfs-daemons \
          gvfs-libs \
          gvfs-backends \
          udisks2 \
          libnss3 \
          libatk1.0-0 \
          libatk-bridge2.0-0 \
          libcups2 \
          libdrm2 \
          libgtk-3-0 \
          libasound2 \
          libxcomposite1 \
          libxdamage1 \
          libxfixes3 \
          libxrandr2 \
          libgbm1 \
          libxshmfence1 \
          libx11-xcb1 \
          libxcb1 \
          libxcb-dri3-0 \
          libxss1 \
          libxtst6 \
          xdg-utils \
          libglib2.0-0 \
          libpango-1.0-0 \
          libcairo2 \
          libgdk-pixbuf2.0-0 \
          libxkbfile1 \
          libsecret-1-0 \
          gnome-keyring \
          libnotify4 \
          libappindicator3-1 \
          dbus-x11 \
          hicolor-icon-theme \
          adwaita-icon-theme \
          gtk-update-icon-cache \
          policykit-1 \
          policykit-1-gnome

        # Update icon cache and mime database
        sudo gtk-update-icon-cache
        sudo update-mime-database /usr/share/mime

        # Create Downloads directory if it does not exist
        mkdir -p ~/Downloads

        # Configure UDisks2
        sudo mkdir -p /etc/udisks2
        echo "[defaults]" | sudo tee /etc/udisks2/udisks2.conf
        echo "force_allow_all=true" | sudo tee -a /etc/udisks2/udisks2.conf
      '

      # Copy and install Z-Library
      echo "Installing Z-Library..."
      if [ -f ~/Downloads/zlibrary.deb ]; then
        # Create a temporary directory in the container
        ${pkgs.distrobox}/bin/distrobox enter ${cfg.container} -- mkdir -p ~/zlibrary-temp

        # Copy the file using regular cp (distrobox mounts home directory)
        ${pkgs.distrobox}/bin/distrobox enter ${cfg.container} -- cp ~/Downloads/zlibrary.deb ~/zlibrary-temp/

        # Install Z-Library using dpkg
        ${pkgs.distrobox}/bin/distrobox enter ${cfg.container} -- bash -c '
          cd ~/zlibrary-temp
          sudo dpkg -i ./zlibrary.deb || {
            echo "Attempting to fix dependencies..."
            sudo apt-get install -f -y
            sudo dpkg -i ./zlibrary.deb
          }
          if ! which z-library > /dev/null; then
            echo "Failed to install Z-Library. Please try again."
            exit 1
          fi
          rm -rf ~/zlibrary-temp
        '
      else
        echo "Could not find zlibrary.deb in ~/Downloads/"
        echo "Please ensure the file exists and try again."
        exit 1
      fi
    fi

    # Launch Z-Library with proper environment
    ${pkgs.distrobox}/bin/distrobox enter ${cfg.container} -- bash -c '
      # Unset problematic NixOS environment variables
      unset NIX_PATH
      unset GIO_EXTRA_MODULES
      unset GVFS_DISABLE_FUSE
      unset GIO_USE_VFS

      # Set up environment variables
      export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/bus"
      export XDG_RUNTIME_DIR="/run/user/$UID"
      export XDG_DATA_DIRS="/usr/share:/usr/local/share"
      export ELECTRON_NO_ATTACH_CONSOLE=1
      export ELECTRON_ENABLE_LOGGING=1
      export ELECTRON_ENABLE_STACK_DUMPING=1
      export GDK_PIXBUF_MODULE_FILE="/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache"
      export FONTCONFIG_PATH="/etc/fonts"

      # Ensure DBUS and gnome-keyring are available
      if ! pgrep -x "gnome-keyring-d" > /dev/null; then
        eval $(dbus-launch --sh-syntax)
        eval $(gnome-keyring-daemon --start --components=secrets)
      fi

      # Start required services
      if ! pgrep -x "gvfsd" > /dev/null; then
        /usr/lib/gvfs/gvfsd &
        sleep 1
      fi

      if ! pgrep -x "udisksd" > /dev/null; then
        sudo udisksd --no-debug &
        sleep 1
      fi

      if ! pgrep -x "polkit" > /dev/null; then
        sudo /usr/lib/policykit-1/polkitd --no-debug &
        sleep 1
      fi

      # Start volume monitor
      if ! pgrep -f "gvfs-udisks2-volume-monitor" > /dev/null; then
        /usr/lib/gvfs/gvfs-udisks2-volume-monitor &
        sleep 1
      fi

      # Launch with proper flags
      z-library --no-sandbox --disable-gpu-sandbox --disable-gpu --in-process-gpu --disable-dev-shm-usage 2>&1 | tee ~/zlibrary.log
    ' || {
      echo "Failed to launch Z-Library. Try removing the container with:"
      echo "distrobox rm ${cfg.container}"
      echo "Then run 'zlibrary' again to recreate it."
      echo "Check ~/zlibrary.log for error details."
      exit 1
    }
  ''; # Added a semicolon here
in {
  options.programs.zlibrary = {
    enable = mkEnableOption "Z-Library via Distrobox";

    container = mkOption {
      type = types.str;
      default = "zlibrary";
      description = "Name of the Distrobox container for Z-Library";
    };

    baseImage = mkOption {
      type = types.str;
      default = "ubuntu:22.04";
      description = "Base image to use for the Distrobox container";
    };
  };

  config = mkIf cfg.enable {
    # Enable required virtualization support
    virtualisation.podman.enable = true;
    virtualisation.containers.enable = true;

    # Install required packages and create desktop entry
    environment.systemPackages = with pkgs; [
      distrobox
      zlibrary-script # Add our custom script
      (makeDesktopItem {
        name = "zlibrary";
        desktopName = "Z-Library";
        exec = "${zlibrary-script}/bin/zlibrary";
        icon = "book";
        comment = "Z-Library via Distrobox";
        categories = ["Office" "Education"];
        terminal = false;
      })
    ];
  };
}
