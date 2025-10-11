{ pkgs }:

{
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

      # Create symlink
      echo "Creating symlink: $PKU_FILE -> $OSLAB_FILE"
      ln -s "$OSLAB_FILE" "$PKU_FILE"

      echo "✓ Done! $RELATIVE_PATH is now symlinked from oslab25"
      ls -la "$PKU_FILE"
    '';
  };
}
