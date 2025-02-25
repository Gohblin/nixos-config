{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.minecraft-server;

  # Create a custom package that contains only the necessary Java components
  javaVersions = pkgs.symlinkJoin {
    name = "minecraft-java-versions";
    paths = [
      (pkgs.jdk8.override { enableJavaFX = false; })
      (pkgs.jdk11.override { enableJavaFX = false; })
      (pkgs.jdk17.override { enableJavaFX = false; })
    ];
    postBuild = ''
      # Create version-specific directories
      mkdir -p $out/java-versions/{8,11,17}
      
      # Create symlinks for each Java version
      ln -s ${pkgs.jdk8}/bin/java $out/java-versions/8/java
      ln -s ${pkgs.jdk11}/bin/java $out/java-versions/11/java
      ln -s ${pkgs.jdk17}/bin/java $out/java-versions/17/java
    '';
  };

  # Helper function to detect required Java version from server jar
  detectJavaVersion = pkgs.writeScript "detect-java-version.sh" ''
    #!${pkgs.bash}/bin/bash
    SERVER_JAR="$1"
    SERVER_SCRIPT="$2"

    if ! [ -f "$SERVER_JAR" ]; then
      echo "17" # Default to Java 17 if jar not found
      exit 0
    fi

    # Check if this is a Fabric server
    if grep -q "fabric" "$SERVER_SCRIPT" || [[ "$SERVER_JAR" == *"fabric"* ]]; then
      # Modern Fabric servers typically need Java 17
      echo "17"
      exit 0
    fi

    # Use strings and grep to analyze jar contents
    if ${pkgs.binutils}/bin/strings "$SERVER_JAR" | grep -q "Java 17"; then
      echo "17"
    elif ${pkgs.binutils}/bin/strings "$SERVER_JAR" | grep -q "Java 11"; then
      echo "11"
    else
      # Check manifest for version hints
      if ${pkgs.unzip}/bin/unzip -p "$SERVER_JAR" META-INF/MANIFEST.MF 2>/dev/null | grep -q "Multi-Release: true"; then
        case "$(${pkgs.unzip}/bin/unzip -p "$SERVER_JAR" META-INF/MANIFEST.MF | grep "Implementation-Version" || echo "")" in
          *1.17*|*1.18*|*1.19*|*1.20*)
            echo "17"
            ;;
          *1.13*|*1.14*|*1.15*|*1.16*)
            echo "11"
            ;;
          *)
            echo "8"
            ;;
        esac
      else
        # Additional check for Fabric/Forge markers
        if ${pkgs.unzip}/bin/unzip -l "$SERVER_JAR" | grep -q "fabric"; then
          echo "17"
        else
          echo "8"
        fi
      fi
    fi
  '';

  # Wrapper script to run Minecraft servers
  mcServerWrapper = pkgs.writeScriptBin "run-mc-server" ''
    #!${pkgs.bash}/bin/bash

    if [ $# -lt 1 ]; then
      echo "Usage: $0 <server-script.sh> [additional args...]"
      exit 1
    fi

    SERVER_SCRIPT="$1"
    shift

    if ! [ -f "$SERVER_SCRIPT" ]; then
      echo "Error: Server script '$SERVER_SCRIPT' not found!"
      exit 1
    fi

    # Find server jar in the script
    SERVER_JAR=$(grep -o '[^[:space:]]*\.jar' "$SERVER_SCRIPT" | head -n1)
    
    if [ -z "$SERVER_JAR" ]; then
      echo "Warning: Could not detect server jar in script, using default Java 17"
      JAVA_VERSION="17"
    else
      JAVA_VERSION=$(${detectJavaVersion} "$SERVER_JAR" "$SERVER_SCRIPT")
    fi

    # Select appropriate Java version
    JAVA_CMD="${javaVersions}/java-versions/$JAVA_VERSION/java"
    
    echo "Using Java $JAVA_VERSION: $JAVA_CMD"

    # Make script executable if it isn't already
    chmod +x "$SERVER_SCRIPT"

    # Set JAVA_HOME for the selected version
    export JAVA_HOME="$(dirname $(dirname $(readlink -f $JAVA_CMD)))"
    export PATH="$JAVA_HOME/bin:$PATH"

    # Run the server script with the detected Java version
    exec env JAVA="$JAVA_CMD" "$SERVER_SCRIPT" "$@"
  '';

in {
  options.programs.minecraft-server = {
    enable = mkEnableOption "Minecraft server wrapper";

    package = mkOption {
      type = types.package;
      default = mcServerWrapper;
      description = "The Minecraft server wrapper package";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to include in the wrapper's environment";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ 
      cfg.package 
      javaVersions
      pkgs.bash
      pkgs.unzip
      pkgs.binutils
      pkgs.coreutils
    ] ++ cfg.extraPackages;
  };
}
