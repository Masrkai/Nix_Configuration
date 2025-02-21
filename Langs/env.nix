{ config, lib, pkgs, ... }:

let
  # Path composition utilities
  mkLibraryPath = paths: lib.makeLibraryPath (lib.filter (x: x != null) paths);

  # Get target architecture triple (e.g., x86_64-unknown-linux-gnu)
  targetTriple = pkgs.stdenv.hostPlatform.config;

  # Core compiler paths
  compilerPaths = {
    includes = {
      cpp = [
        "${pkgs.glibc.dev}/include"
        "${pkgs.stdenv.cc.cc}/include"
        # Main C++ headers
        "${pkgs.stdenv.cc.cc}/include/c++/${pkgs.stdenv.cc.cc.version}"
        # Architecture-specific headers (fixed)
        "${pkgs.stdenv.cc.cc}/include/c++/${pkgs.stdenv.cc.cc.version}/${targetTriple}"
      ];
    };
    libraries = [
      pkgs.glibc
      pkgs.stdenv.cc.cc.lib
    ];
  };

  # Domain-specific libraries
  domainLibs = {
    scientific = [
      pkgs.boost185
      pkgs.eigen
      pkgs.nlohmann_json
    ];
  };

in {
  environment = lib.mkMerge [{
    pathsToLink = [ "/include" "/lib" ];

    variables = lib.mkMerge [
      {
        # Include paths with architecture-specific directories plus scientific library headers
        CPLUS_INCLUDE_PATH = lib.concatStringsSep ":"
          (compilerPaths.includes.cpp ++ (map (p: "${p}/include") domainLibs.scientific));

        # Library paths
        LIBRARY_PATH = mkLibraryPath (compilerPaths.libraries ++ domainLibs.scientific);


        # Compiler flags
        NIX_CXXFLAGS_COMPILE = toString [
          "--gcc-toolchain=${pkgs.stdenv.cc}"
          "-stdlib=libstdc++"
          "-pthread"
        ];

        # Linker flags
        NIX_LDFLAGS = toString [
          "-L${pkgs.stdenv.cc.cc.lib}/lib"
          "-Wl,-rpath,${pkgs.stdenv.cc.cc.lib}/lib"
          "-lpthread"
          "-lstdc++"
        ];
      }

      {
        LD_LIBRARY_PATH = lib.mkMerge [
          (lib.mkForce (mkLibraryPath [
            pkgs.glibc
            pkgs.stdenv.cc.cc.lib
            pkgs.boost185
            pkgs.eigen
            pkgs.nlohmann_json
          ]))
          "\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
        ];
      }
    ];
  }];
}
