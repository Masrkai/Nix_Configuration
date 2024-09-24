{ lib, stdenv, makeWrapper, fetchFromGitHub
  # Required
, iw , tmux , bash , gawk , procps , gnused , gnugrep , pciutils , iproute2 , aircrack-ng , coreutils-full
  # X11 Front
, xorg, xterm
  # what the author calls "Internals"
, usbutils, wget, ethtool, util-linux, ccze
  # Optionals
  # Missing in nixpkgs: beef, hostapd-wpe
, john , mdk4 , bully , crunch , asleap , openssl , dnsmasq , hashcat , hostapd , hcxtools , lighttpd , nftables , ettercap , pixiewps , bettercap , hcxdumptool , wireshark-cli , reaverwps-t6x
  # Undocumented requirements (there is also ping)
, curl , glibc , ncurses , systemd , networkmanager , apparmor-bin-utils
  # Support groups
, supportWpaWps ? true # Most common use-case
, supportHashCracking ? true
, supportEvilTwin ? true
, supportX11 ? false # Allow using xterm instead of tmux, hard to test
}:
let
  deps = [
    iw tmux bash curl wget gawk ccze glibc procps gnused systemd ncurses gnugrep ethtool pciutils iproute2 usbutils util-linux aircrack-ng coreutils-full networkmanager

  ] ++ lib.optionals supportWpaWps [
    bully pixiewps reaverwps-t6x

  ] ++ lib.optionals supportHashCracking [
    john asleap crunch hashcat hcxtools hcxdumptool wireshark-cli

  ] ++ lib.optionals supportEvilTwin [
    mdk4 hostapd dnsmasq openssl nftables lighttpd ettercap bettercap apparmor-bin-utils

  ] ++ lib.optionals supportX11 [
    xterm
    xorg.xset
    xorg.xdpyinfo
  ];
in
stdenv.mkDerivation rec {
  pname = "airgeddon";
  version = "11.31";

  src = fetchFromGitHub {
    owner = "v1s1t0r1sh3r3";
    repo = "airgeddon";
    rev = "v${version}";
    hash = "sha256-tflUIjTBKgbFfPD4kSEBTGvpodWaseelOc7fPUwR+pk=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];


  postPatch = ''
    patchShebangs airgeddon.sh
    sed -i '
      s|AIRGEDDON_AUTO_UPDATE=true|AIRGEDDON_AUTO_UPDATE=false|
      s|AIRGEDDON_SKIP_INTRO=false|AIRGEDDON_SKIP_INTRO=true|
      s|AIRGEDDON_PLUGINS_ENABLED=true|AIRGEDDON_PLUGINS_ENABLED=false|
      s|AIRGEDDON_WINDOWS_HANDLING=xterm|AIRGEDDON_WINDOWS_HANDLING=xterm|
      ' .airgeddonrc

    # Modify the script to use a writable directory for runtime files
    sed -i 's|scriptfolder=".*"|scriptfolder="$HOME/.config/airgeddon"|' airgeddon.sh
    sed -i 's|language_strings_file=".*"|language_strings_file="$scriptfolder/language_strings.sh"|' airgeddon.sh
    sed -i 's|saved_arc_path=".*"|saved_arc_path="$scriptfolder/.airgeddonrc"|' airgeddon.sh

    # Ensure the script creates the necessary directory
    sed -i '1a mkdir -p "$HOME/.config/airgeddon"' airgeddon.sh
    sed -i '2a cp -n ${placeholder "out"}/share/airgeddon/{.airgeddonrc,language_strings.sh,known_pins.db} "$HOME/.config/airgeddon/"' airgeddon.sh
  '';

 postInstall = ''
    wrapProgram $out/bin/airgeddon \
      --prefix PATH : ${lib.makeBinPath deps} \
      --run 'mkdir -p "$HOME/.config/airgeddon"' \
      --run 'cp -n ${placeholder "out"}/share/airgeddon/{.airgeddonrc,language_strings.sh,known_pins.db} "$HOME/.config/airgeddon/"'
  '';

  installPhase = ''
    runHook preInstall
    install -Dm 755 airgeddon.sh "$out/bin/airgeddon"
    install -dm 755 "$out/share/airgeddon"
    cp -dr .airgeddonrc known_pins.db language_strings.sh plugins/ "$out/share/airgeddon/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Multi-use TUI to audit wireless networks";
    homepage = "https://github.com/v1s1t0r1sh3r3/airgeddon";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ offline ];
    platforms = platforms.linux;
  };
}