{ stdenv, lib, fetchurl, appimageTools, makeWrapper, electron, nodejs }:

stdenv.mkDerivation rec {
  pname = "siteone-crawler-gui";
  version = "1.0.8";

  src = fetchurl {
    url = "https://github.com/janreges/siteone-crawler-gui/releases/download/v${version}/SiteOne-Crawler-linux-x64-${version}.AppImage";
    sha256 = "sha256-KG9z0+mscbwQR4gS3fDIAGQAkfRR4/82WcH7oPH39Ow=";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper electron nodejs ];

   
  # Build phase
  buildPhase = ''
    # Navigate to the source directory
    cd ${appimageContents}/src

    # Initialize submodules
    git submodule update --init --recursive

    # Install dependencies
    npm install

    # Build the application (if a build script is defined in package.json)
    npm run build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname} $out/share/applications

    cp -a ${appimageContents}/locales $out/share/${pname}
    cp -a ${appimageContents}/resources $out/share/${pname}
    
    # Copy desktop entry and icons
    cp -a ${appimageContents}/siteone-crawler-gui.desktop $out/share/applications/${pname}.desktop
    cp -a ${appimageContents}/usr/share/icons $out/share

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${appimageContents}/AppRun $out/bin/${pname} \
      --add-flags "$out/share/${pname}/resources/app.asar"
  '';


  meta = with lib; {
    description = "Multi-platform desktop application with the included SiteOne Crawler.";
    homepage = "https://github.com/janreges/siteone-crawler-gui";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ offline ];
    mainProgram = "siteone-crawler-gui";
  };
}