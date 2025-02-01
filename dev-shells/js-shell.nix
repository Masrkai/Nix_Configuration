{ nixpkgsConfig ? {}
, enableTypeScript ? true
, enableMonitoring ? false
, nodeVersion ? "23"
}:
let
  nixpkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
    } // nixpkgsConfig.config or {};
    overlays = nixpkgsConfig.overlays or [];
  };
  inherit (nixpkgs) pkgs lib;

  monitoring-pkgs = with pkgs; lib.optionals enableMonitoring [
    htop
    iotop
    nethogs
  ];

  node = pkgs."nodejs_${nodeVersion}";

  # Common development tools
  dev-tools = with pkgs; [
    git
    gcc
    gdb
    cmake
    pkg-config
    openssl
    sqlite
  ];

  # JavaScript-specific tools
  js-tools = with pkgs; [
    node
    yarn
    nodePackages.pnpm
    nodePackages.npm-check-updates
    # Linters and formatters
    nodePackages.eslint
    nodePackages.prettier
    # Build tools
    nodePackages.webpack
    nodePackages.webpack-cli

    # # Testing
    # nodePackages.vitest
  ] ++ lib.optionals enableTypeScript [
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.ts-node
  ];

  setupEnvScript = pkgs.writeTextFile {
    name = "setup-env";
    destination = "/bin/setup-env";
    text = ''
      #!/usr/bin/env bash
      # Variables exported from Nix
      export NODE_VERSION="${nodeVersion}"
      export PATH="$PWD/node_modules/.bin:$PATH"

      # Setup npm configuration
      npm config set prefix "$PWD/.npm-global"
      export PATH="$PWD/.npm-global/bin:$PATH"

      # Initialize git config if needed
      if [ ! -f .git/config ]; then
        git config --global init.defaultBranch main
      fi

      # Create .npmrc if it doesn't exist
      if [ ! -f .npmrc ]; then
        echo "save-exact=true" > .npmrc
        echo "engine-strict=true" >> .npmrc
      fi
    '';
    executable = true;
    checkPhase = ''
      ${pkgs.bash}/bin/bash -n $out/bin/setup-env
    '';
  };

in pkgs.mkShell {
  buildInputs = dev-tools ++ js-tools ++ monitoring-pkgs ++ [ setupEnvScript ];

  shellHook = ''
    # Set up environment
    export PATH="$PWD/node_modules/.bin:$PATH"
    export NODE_PATH="$PWD/node_modules"
    export NPM_CONFIG_PREFIX="$PWD/.npm-global"

    # Source the setup script
    source ${setupEnvScript}/bin/setup-env

    # Print environment info
    echo "Node.js development environment activated:"
    echo "Node version: $(node --version)"
    echo "NPM version: $(npm --version)"
    ${if enableTypeScript then "echo \"TypeScript version: $(tsc --version)\"" else ""}
  '';

  # Environment variables for development
  LANG = "en_US.UTF-8";
  EDITOR = "vim";

  # Add SSL certificates
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
}