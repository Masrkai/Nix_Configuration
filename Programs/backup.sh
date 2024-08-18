#!/bin/sh

# Define color variables
Cyan='\033[0;36m'
LightGreen='\033[1;32m'
NC='\033[0m'       # No Color

# Define paths
base_dir="/home/masrkai/Programs/System"
nix_config_dir="$base_dir/Nix_Configuration"
src_nixos="/etc/nixos/"

# Define GitHub repository URL
nix_config_repo="git@github.com:Masrkai/Nix_Configuration.git"

# Create necessary directory
mkdir -p "$nix_config_dir"

# Function to copy files, commit changes, and push to GitHub
copy_commit_and_push() {
    src=$1
    dest=$2
    repo_dir=$3
    commit_msg=$4
    github_repo=$5

    if [ -e "$src" ]; then
        # Use rsync to copy files
        rsync -av "$src" "$dest"
        rm -rf "$nix_config_dir/secrets.nix"
        
        cd "$repo_dir"
        
        # Initialize git repository if it doesn't exist
        if [ ! -d .git ]; then
            git init
            git remote add origin "$github_repo"
        else
            # Ensure the remote URL is using SSH
            git remote set-url origin "$github_repo"
        fi
        
        # Add all changes, including new files, but respect .gitignore
        git add -A
        
        # Commit changes
        git commit -m "$commit_msg"
        
        # Push changes to GitHub using SSH
        if GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_rsa -o IdentitiesOnly=yes" git push -u origin main --force; then
            echo -e "${LightGreen}Changes pushed to GitHub for ${Cyan}$src${NC}"
        else
            echo -e "${Cyan}Warning: Failed to push changes for ${src} to GitHub.${NC}"
            echo "Error details:"
            GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_rsa -o IdentitiesOnly=yes" git push -u origin main --force 2>&1
        fi
    else
        echo -e "${Cyan}Warning: ${src} does not exist.${NC}"
    fi
}

# Copy, commit, and push NixOS configuration
copy_commit_and_push "$src_nixos" "$nix_config_dir/" "$nix_config_dir" "Update NixOS configuration" "$nix_config_repo"

# Output completion message
echo -e "${LightGreen}The Configuration of ${Cyan}nixos ${LightGreen}was copied, committed, and pushed to GitHub ${Cyan}successfully.${NC}"