{ lib
, fetchFromGitLab
, buildNpmPackage
, autoPatchelfHook
, buildDotnetModule
, dotnetCorePackages
, makeDesktopItem
, copyDesktopItems
, wrapGAppsHook

# Runtime dependencies
, icu
, atk
, nss
, libz
, xorg
, gtk3
, glib
, nspr
, dbus
, cups
, udev
, mesa
, libGL
, cairo
, pango
, expat
, libdrm
, openssl
, alsa-lib
, libsecret
, libxkbcommon
}:

let
  pname = "grayjay-desktop";
  version = "5";

  grayjay-web = buildNpmPackage {
    pname = "grayjay-desktop-web";
    inherit version;
    src = "${grayjay-desktop-src}/Grayjay.Desktop.Web";

    npmDepsHash = "sha256-pTEbMSAJwTY6ZRriPWfBFnRHSYufSsD0d+hWGz35xFM=";

    # Use a more specific output path for web assets
    installPhase = ''
      runHook preInstall
      mkdir -p $out/web
      cp -r ./dist/* $out/web/
      runHook postInstall
    '';
  };

  grayjay-desktop-src = fetchFromGitLab {
    domain = "gitlab.futo.org";
    owner = "VideoStreaming";
    repo = "Grayjay.Desktop";
    tag = "${version}";
    hash = "sha256-xrbYghNymny6MQrvFn++GaI+kUoOphPQMWcqH47U1Yg=";
    fetchSubmodules = true;
    fetchLFS = true;
  };

  grayjay-desktop = buildDotnetModule rec {
    inherit pname version;
    src = grayjay-desktop-src;

    patches = [ ./launch.patch ./wwwroot.patch ];

    executables = [ "Grayjay" ];

    dotnet-sdk = dotnetCorePackages.sdk_8_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

    nugetDeps = ./deps.json;
    projectFile = "Grayjay.Desktop.CEF/Grayjay.Desktop.CEF.csproj";

    nativeBuildInputs = [
      autoPatchelfHook
      wrapGAppsHook
      copyDesktopItems
    ];

    desktopItems = [
      (makeDesktopItem {
        name = pname;
        exec = "Grayjay";
        icon = pname;
        desktopName = "Grayjay";
        comment = "Media aggregator for video platforms";
        categories = [ "AudioVideo" "Network" ];
      })
    ];

    postInstall = ''
      # Create proper directory structure
      mkdir -p $out/lib/${pname}/wwwroot
      
      # Copy web assets
      cp -r ${grayjay-web}/web $out/lib/${pname}/wwwroot/
      
      # Remove portable indicator
      rm -f $out/lib/${pname}/Portable
      
      # Install icon
      install -Dm644 "${src}/Grayjay.Desktop.CEF/logo.ico" "$out/share/icons/hicolor/256x256/apps/${pname}.ico"
      install -Dm644 "${src}/Grayjay.Desktop.CEF/grayjay.png" "$out/share/icons/hicolor/256x256/apps/${pname}.png"
    '';
    
    # Configure autoPatchelf properly
    dontAutoPatchelf = true;
    preFixup = ''
      addAutoPatchelfSearchPath $out/lib/${pname}/cef
    '';
    postFixup = ''
      autoPatchelf $out/lib/${pname}/cef/dotcefnative

      # Ensure GLib schemas are found
      gappsWrapperArgs+=(
        --prefix XDG_DATA_DIRS : "${glib.out}/share/gsettings-schemas/${glib.name}"
        --prefix XDG_DATA_DIRS : "${gtk3.out}/share/gsettings-schemas/${gtk3.name}"
      )
    '';

    buildInputs = [
      glib
      gtk3
      xorg.libX11
    ];

    runtimeDeps = [
      icu
      libz
      openssl # For updater

      # X11 dependencies
      xorg.libxcb
      xorg.libX11
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXdamage
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXtst
      xorg.libXi

      # GTK and related dependencies
      atk
      nss
      nspr
      gtk3
      glib
      dbus
      # dbus.lib
      cups
      udev
      mesa
      libGL
      cairo
      expat
      pango
      libdrm
      alsa-lib
      libsecret
      libxkbcommon
    ];

    meta = with lib; {
      description = "Media aggregator for video platforms";
      homepage = "https://grayjay.app/";
      license = licenses.agpl3Plus;
      # maintainers = with maintainers; [ /* your name here */ ];
      platforms = platforms.linux;
      mainProgram = "Grayjay";
    };
  };
in
  grayjay-desktop