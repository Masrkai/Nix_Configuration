#!/bin/sh

# *Define color variables
Cyan='\033[0;36m'
LightGreen='\033[1;32m'
NC='\033[0m'       # Reset Color

# *Create the .vscode directory if it doesn't exist
mkdir -p .vscode

# *Define the source and destination paths
src_dir="/home/masrkai/Templates/C++"
dest_dir="."

# *List of files to copy
files=(
  "main.cpp"
  "shell.nix"
  "CMakeLists.txt"
  ".vscode/tasks.json"
  ".vscode/launch.json"
)

# *Copy files to the destination
for file in "${files[@]}"; do
  cp "$src_dir/${file#./}" "$dest_dir/${file#./}" 2>/dev/null
done

# *Output completion message
echo -e "${LightGreen}VS Codium C++ configuration setup completed.${NC}"