{ pkgs }:

{

  screen-shot-drag = pkgs.writeShellApplication {
    name = "screen-shot-drag";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''grim -l 0 -g "$(slurp)" - | wl-copy'';
  };
  pintos-symlink = pkgs.writeShellApplication {
    name = "pintos-symlink";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      set -e

      if [ $# -ne 1 ]; then
          echo "Usage: pintos-symlink <relative-path>"
          echo "Example: pintos-symlink threads/thread.c"
          exit 1
      fi

      RELATIVE_PATH="$1"
      BASE_DIR="$HOME/itu/operating_systems_and_C"
      PKU_DIR="$BASE_DIR/pintos/src"
      OSLAB_DIR="$BASE_DIR/oslab25"
      PKU_FILE="$PKU_DIR/$RELATIVE_PATH"
      OSLAB_FILE="$OSLAB_DIR/$RELATIVE_PATH"

      # Check if files exist
      if [ ! -f "$PKU_FILE" ]; then
          echo "Error: PKU file not found: $PKU_FILE"
          exit 1
      fi

      if [ ! -f "$OSLAB_FILE" ]; then
          echo "Error: oslab25 file not found: $OSLAB_FILE"
          exit 1
      fi

      # Backup PKU file
      echo "Backing up: $PKU_FILE -> ''${PKU_FILE}.backup"
      cp "$PKU_FILE" "''${PKU_FILE}.backup"

      # Remove original
      echo "Removing: $PKU_FILE"
      rm "$PKU_FILE"

      # Calculate relative path from PKU file's directory to OSLAB file
      PKU_DIR_PATH=$(dirname "$PKU_FILE")
      RELATIVE_LINK=$(realpath --relative-to="$PKU_DIR_PATH" "$OSLAB_FILE")

      # Create relative symlink
      echo "Creating relative symlink: $PKU_FILE -> $RELATIVE_LINK"
      ln -s "$RELATIVE_LINK" "$PKU_FILE"

      echo "✓ Done! $RELATIVE_PATH is now symlinked from oslab25"
      ls -la "$PKU_FILE"
    '';
  };
}
