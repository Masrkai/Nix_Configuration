#!/bin/sh

# *Define color variables
Cyan='\033[0;36m'
LightGreen='\033[1;32m'
NC='\033[0m'       # Reset Color

  mkdir -p src
  echo '#include <iostream>

  int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
  }' > src/main.cpp

  echo '{ pkgs ? import <nixpkgs> {} }:

      let
        stdenv = pkgs.stdenv;
        gcc = pkgs.gcc;
        lib = pkgs.lib;
      in
      stdenv.mkDerivation {
        name = "CMS";

        # Specify your source files here
        src = ./src;

        # Compiler flags
        CXXFLAGS = "-std=c++23";

        # Linker flags (if any)
        LDFLAGS = "";

        buildInputs = [ gcc ];

        # Build command
        buildPhase = ''
          mkdir -p $out/bin
          g++ $CXXFLAGS -o $out/bin/output.exe $src/main.cpp $LDFLAGS
        '';

        # Optional install phase if you want to do something specific
        # installPhase = ''
        #   echo "Installation phase"
        # '';

        meta = with lib; {
          description = "CMS";
          license = licenses.mit;
          platforms = platforms.linux;
        };
      }' > default.nix

  echo 'result' > .gitignore

  echo '# C++ Project'

# *Output completion message
echo -e "${LightGreen}C++ development environment setup complete.${NC}"