{ lib, stdenv, fetchFromGitHub, fetchurl, zlib, openssl, libiconv
, mkDerivation, cmake, pkg-config, makeWrapper
, qtbase, qtmultimedia, autoconf, automake, libtool }:

let
  httrack = stdenv.mkDerivation rec {
    pname = "httrack";
    version = "1.0";

    src = fetchFromGitHub {
      owner = "Masrkai";
      repo = "httrack";
      rev = "1.0";
      sha256 = "sha256-YiUEHZicoxViAHS9GOpEfyNKGNShOMTokYDv8aXdM5Y="; # Replace with actual SHA256 hash
    };

    buildInputs = [ libiconv openssl zlib ];
    nativeBuildInputs = [ autoconf automake libtool ];

    preConfigure = ''
      ./autogen.sh
    '';

    configureFlags = [
      "--enable-https"
      "--enable-online-unit-tests=no"
    ];

    enableParallelBuilding = true;

    meta = with lib; {
      description = "Easy-to-use offline browser / website mirroring utility (custom version)";
      homepage = "https://github.com/Masrkai/httrack";
      license = licenses.gpl3;
      platforms = platforms.unix;
    };
  };

  httraqt = mkDerivation rec {
    pname = "httraqt";
    version = "1.4.9";

    src = fetchurl {
      url = "mirror://sourceforge/httraqt/${pname}-${version}.tar.gz";
      sha256 = "0pjxqnqchpbla4xiq4rklc06484n46cpahnjy03n9rghwwcad25b";
    };

    buildInputs = [ httrack qtbase qtmultimedia ];

    nativeBuildInputs = [ cmake makeWrapper pkg-config ];

    prePatch = ''
      substituteInPlace cmake/HTTRAQTFindHttrack.cmake \
        --replace /usr/include/httrack/ ${httrack}/include/httrack/

      substituteInPlace distribution/posix/CMakeLists.txt \
        --replace /usr/share $out/share

      substituteInPlace desktop/httraqt.desktop \
        --replace Exec=httraqt Exec=$out/bin/httraqt

      substituteInPlace sources/main/httraqt.cpp \
        --replace /usr/share/httraqt/ $out/share/httraqt
    '';

    meta = with lib; {
      broken = stdenv.isDarwin;
      description = "Easy-to-use offline browser / website mirroring utility - QT frontend (custom version)";
      mainProgram = "httraqt";
      homepage = "http://www.httrack.com";
      license = licenses.gpl3;
      platforms = platforms.unix;
    };
  };
in
stdenv.mkDerivation {
  pname = "httrack-bundle";
  version = httrack.version;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${httrack}/bin/* $out/bin/
    ln -s ${httraqt}/bin/* $out/bin/
  '';

  meta = with lib; {
    description = "Bundled httrack and httraqt (custom versions)";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}