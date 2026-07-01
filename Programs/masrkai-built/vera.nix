# vera.nix
{ lib
, rustPlatform
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, makeWrapper
, autoPatchelfHook
, pkg-config
, fontconfig
, freetype
, expat
, wayland
, libxkbcommon
, libGL
, stdenv
, zenity
}:

let
  runtimeLibs = [
    fontconfig
    freetype
    expat
    wayland
    libxkbcommon
    libGL
    stdenv.cc.cc.lib
  ];
in

rustPlatform.buildRustPackage rec{
  pname = "vera";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Masrkai";
    repo  = "Vera";
    rev   = "69430fb178ac9490374d93f826d715eaea0923b3";
    hash  = "sha256-QkHbogsVdFC/2ID4RhjdH39OHNFzB0RX1klPQifs5Y8=";
  };

  cargoHash = "sha256-S1nmCtKTJRek7ZhRj3MQ51LIaoxnQ0WE70PVw168L8s=";

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs ++ [ zenity ];

  desktopItems = [
    (makeDesktopItem {
      name = "vera";
      desktopName = "Vera";
      exec = "vera %F";
      icon = "vera";
      comment = "Image metadata viewer";
      categories = [ "Graphics" "Viewer" ];
      mimeTypes = [ "image/jpeg" "image/png" "image/tiff" "image/bmp" ];
      terminal = false;
    })
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp ${src}/assets/Vera.svg $out/share/icons/hicolor/scalable/apps/vera.svg

    wrapProgram $out/bin/vera \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --prefix PATH : ${lib.makeBinPath [ zenity ]}
  '';

  meta = {
    description = "Image metadata viewer";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}