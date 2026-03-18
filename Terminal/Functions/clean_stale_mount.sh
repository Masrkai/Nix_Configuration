clean_stale_mount() {
    local mount_name="$1"
    local user="${2:-$USER}"  # Use current user if not specified
    local mount_path="/run/media/$user/$mount_name"

    if [ -z "$mount_name" ]; then
        echo "Error: Please provide a mount name"
        echo "Usage: clean_stale_mount <mount_name> [username]"
        return 1
    fi

    echo "Cleaning stale mount: $mount_path"

    # Try to unmount if mounted
    sudo umount "$mount_path" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Unmounted $mount_path"
    else
        echo "ℹ Nothing to unmount (not mounted or already unmounted)"
    fi

    # Remove the stale directory
    if [ -d "$mount_path" ]; then
        sudo rm -rf "$mount_path"
        if [ $? -eq 0 ]; then
            echo "✓ Removed stale directory $mount_path"
            echo "✓ Done! You can now reconnect your drive."
        else
            echo "✗ Failed to remove directory"
            return 1
        fi
    else
        echo "ℹ Directory doesn't exist (already cleaned)"
    fi
}