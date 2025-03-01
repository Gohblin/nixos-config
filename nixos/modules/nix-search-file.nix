{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.nix-search-file;
in {
  options.services.nix-search-file = {
    enable = mkEnableOption "nix-search-file utility";

    defaultSearchPath = mkOption {
      type = types.str;
      default = "/etc/nixos";
      description = "Default directory to search in if none is specified";
    };

    maxContextLines = mkOption {
      type = types.int;
      default = 1;
      description = "Number of context lines to show before and after the match";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nix-search-file" ''
                #!/usr/bin/env bash

                # Default search directory from module configuration
                DEFAULT_SEARCH_DIR="${cfg.defaultSearchPath}"
                CONTEXT_LINES="${toString cfg.maxContextLines}"

                # Help function
                function show_help {
                  echo "Usage: nix-search-file [OPTIONS] PATTERN"
                  echo ""
                  echo "Search for PATTERN in Nix configuration files"
                  echo ""
                  echo "Options:"
                  echo "  -d, --directory DIR    Directory to search (default: ${cfg.defaultSearchPath})"
                  echo "  -c, --context LINES    Number of context lines to show (default: ${toString cfg.maxContextLines})"
                  echo "  -h, --help             Show this help message"
                  echo ""
                  echo "Example:"
                  echo "  nix-search-file \"programs.steam.enable = true;\""
                  echo "  nix-search-file -d ~/nixos-config \"services.xserver.enable\""
                  echo ""
                  echo "Keybindings in fzf:"
                  echo "  Enter      Open in EDITOR at the selected line"
                  echo "  Ctrl+E     Open in sudo vim at the selected line"
                }

                # Parse arguments
                SEARCH_DIR="$DEFAULT_SEARCH_DIR"
                PATTERN=""

                while [[ $# -gt 0 ]]; do
                  case "$1" in
                    -d|--directory)
                      SEARCH_DIR="$2"
                      shift 2
                      ;;
                    -c|--context)
                      CONTEXT_LINES="$2"
                      shift 2
                      ;;
                    -h|--help)
                      show_help
                      exit 0
                      ;;
                    *)
                      PATTERN="$1"
                      shift
                      ;;
                  esac
                done

                # Check if pattern is provided
                if [[ -z "$PATTERN" ]]; then
                  echo "Error: No search pattern provided"
                  show_help
                  exit 1
                fi

                # Convert to absolute path and normalize
                SEARCH_DIR=$(realpath -m "$SEARCH_DIR")

                # Check if directory exists
                if [[ ! -d "$SEARCH_DIR" ]]; then
                  echo "Error: Directory '$SEARCH_DIR' does not exist"
                  exit 1
                fi

                # Check if fzf is installed
                if ! command -v fzf >/dev/null 2>&1; then
                  echo "Error: fzf is not installed. Please install it for interactive search."
                  exit 1
                fi

                # Perform the search using grep
                GREP_RESULTS=$(grep -n -r --include="*.nix" "$PATTERN" "$SEARCH_DIR" 2>/dev/null)

                if [[ -z "$GREP_RESULTS" ]]; then
                  echo -e "\033[33mNo matches found.\033[0m"
                  exit 0
                fi

                # Count matches for statistics
                COUNT=$(echo "$GREP_RESULTS" | wc -l)

                # Create a temporary directory to store processed results
                TEMP_DIR=$(mktemp -d)
                RESULTS_FILE="$TEMP_DIR/results.txt"
                PREVIEW_SCRIPT="$TEMP_DIR/preview.sh"
                OPEN_SCRIPT="$TEMP_DIR/open.sh"
                SUDO_VIM_SCRIPT="$TEMP_DIR/sudo_vim.sh"

                # Write the results to a file with proper formatting
                {
                  # Process each result line
                  echo "$GREP_RESULTS" | while IFS= read -r line; do
                    filepath=$(echo "$line" | cut -d':' -f1)
                    lineno=$(echo "$line" | cut -d':' -f2)
                    content=$(echo "$line" | cut -d':' -f3-)

                    # Get relative path
                    relpath=$(realpath --relative-to="$SEARCH_DIR" "$filepath" 2>/dev/null || echo "$filepath")

                    # Format the result line
                    # Store the absolute path in a hidden field, followed by a tab, then the displayed line
                    # This lets us retrieve the full path later without parsing issues
                    echo -e "$filepath\t\033[1;36m$relpath\033[0m:\033[1;33m$lineno\033[0m:$content"
                  done
                } > "$RESULTS_FILE"

                # Create header with search info
                HEADER="\033[1mSearching for:\033[0m '$PATTERN' \033[1min\033[0m $SEARCH_DIR ($COUNT matches)"

                # Create preview script
                cat > "$PREVIEW_SCRIPT" << 'EOF'
        #!/usr/bin/env bash
        line="$1"

        # Extract the hidden filepath and visible parts
        filepath=$(echo "$line" | cut -f1)
        display=$(echo "$line" | cut -f2-)

        # Extract line number from the display part
        lineno=$(echo "$display" | sed -E 's/\x1B\[[0-9;]*[mK]//g' | cut -d':' -f2)

        # Verify the file exists
        if [[ ! -f "$filepath" ]]; then
          echo -e "\033[31mError: File not found: $filepath\033[0m"
          exit 1
        fi

        # Calculate line range for preview
        start=$((lineno - CONTEXT_LINES > 0 ? lineno - CONTEXT_LINES : 1))
        end=$((lineno + CONTEXT_LINES))

        # Display file header
        echo -e "\033[1;36m$filepath\033[0m:\033[1;33m$lineno\033[0m\n"

        # Display file content with line numbers and highlight the selected line
        awk -v start="$start" -v end="$end" -v lineno="$lineno" '
          NR >= start && NR <= end {
            if (NR == lineno) {
              printf "\033[1;32m%4d │ %s\033[0m\n", NR, $0
            } else {
              printf "\033[90m%4d │ %s\033[0m\n", NR, $0
            }
          }
        ' "$filepath"
        EOF
                chmod +x "$PREVIEW_SCRIPT"

                # Create open script for when user presses Enter
                cat > "$OPEN_SCRIPT" << 'EOF'
        #!/usr/bin/env bash
        line="$1"

        # Extract the hidden filepath and visible parts
        filepath=$(echo "$line" | cut -f1)
        display=$(echo "$line" | cut -f2-)

        # Extract line number from the display part
        lineno=$(echo "$display" | sed -E 's/\x1B\[[0-9;]*[mK]//g' | cut -d':' -f2)

        # Verify the file exists
        if [[ ! -f "$filepath" ]]; then
          echo -e "\033[31mError: File not found: $filepath\033[0m"
          exit 1
        fi

        # Print information about the selected file
        echo -e "\nOpening \033[1;36m$filepath\033[0m at line \033[1;33m$lineno\033[0m\n"

        # Try to open the file with the default EDITOR at the correct line
        if [[ -n "$EDITOR" ]]; then
          if [[ "$EDITOR" == *"vim"* || "$EDITOR" == *"nvim"* ]]; then
            $EDITOR "+$lineno" "$filepath"
          elif [[ "$EDITOR" == *"emacs"* ]]; then
            $EDITOR "+$lineno" "$filepath"
          elif [[ "$EDITOR" == *"code"* || "$EDITOR" == *"vscode"* ]]; then
            $EDITOR "$filepath:$lineno"
          else
            # Default fallback
            $EDITOR "$filepath"
          fi
        else
          # If no editor is set, just display the file with less
          less +$lineno "$filepath"
        fi
        EOF
                chmod +x "$OPEN_SCRIPT"

                # Create sudo vim script for when user presses Ctrl+E
                cat > "$SUDO_VIM_SCRIPT" << 'EOF'
        #!/usr/bin/env bash
        line="$1"

        # Extract the hidden filepath and visible parts
        filepath=$(echo "$line" | cut -f1)
        display=$(echo "$line" | cut -f2-)

        # Extract line number from the display part
        lineno=$(echo "$display" | sed -E 's/\x1B\[[0-9;]*[mK]//g' | cut -d':' -f2)

        # Verify the file exists
        if [[ ! -f "$filepath" ]]; then
          echo -e "\033[31mError: File not found: $filepath\033[0m"
          exit 1
        fi

        # Print information about the selected file
        echo -e "\nOpening with sudo vim: \033[1;36m$filepath\033[0m at line \033[1;33m$lineno\033[0m\n"

        # Open the file with sudo vim at the correct line
        sudo vim "+$lineno" "$filepath"
        EOF
                chmod +x "$SUDO_VIM_SCRIPT"

                # Set environment variable for the preview script
                export CONTEXT_LINES="$CONTEXT_LINES"

                # Use FZF for interactive selection
                cat "$RESULTS_FILE" | fzf --ansi \
                                       --header="$HEADER" \
                                       --border rounded \
                                       --layout=reverse \
                                       --no-mouse \
                                       --delimiter='\t' \
                                       --with-nth=2 \
                                       --prompt="Use ↑/↓ to navigate, Enter to open, Ctrl+E for sudo vim > " \
                                       --preview="$PREVIEW_SCRIPT {}" \
                                       --preview-window="right:60%:wrap" \
                                       --bind="enter:execute($OPEN_SCRIPT {})" \
                                       --bind="ctrl-e:execute($SUDO_VIM_SCRIPT {})"

                # Clean up temporary files
                rm -rf "$TEMP_DIR"
      '')
    ];
  };
}
