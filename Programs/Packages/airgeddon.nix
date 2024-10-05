{ lib, stdenv, makeWrapper, fetchFromGitHub
  # Required
, iw, tmux, bash, gawk, procps, gnused, gnugrep, pciutils, iproute2, aircrack-ng, coreutils-full
  # X11 Front
, xorg, xterm
  # Internals
, usbutils, wget, ethtool, util-linux, ccze
  # Optionals
, john, mdk4, bully, crunch, asleap, openssl, dnsmasq, hashcat, hostapd, hcxtools, lighttpd, nftables, ettercap, pixiewps, bettercap, hcxdumptool, wireshark-cli, reaverwps-t6x
  # Undocumented requirements
, curl, glibc, ncurses, systemd, networkmanager, apparmor-bin-utils
  # Support groups
, supportWpaWps ? true
, supportHashCracking ? true
, supportEvilTwin ? true
, supportX11 ? false
}:

let
  deps = [
    iw tmux bash curl wget gawk ccze glibc procps gnused systemd ncurses gnugrep ethtool pciutils iproute2 usbutils util-linux aircrack-ng coreutils-full networkmanager
  ] ++ lib.optionals supportWpaWps [
    bully pixiewps reaverwps-t6x
  ] ++ lib.optionals supportHashCracking [
    john asleap crunch hashcat hcxdumptool wireshark-cli
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

    # Modify default settings in .airgeddonrc
    sed -i '
      s|AIRGEDDON_AUTO_UPDATE=true|AIRGEDDON_AUTO_UPDATE=false|
      s|AIRGEDDON_SKIP_INTRO=false|AIRGEDDON_SKIP_INTRO=false|
      s|AIRGEDDON_PLUGINS_ENABLED=true|AIRGEDDON_PLUGINS_ENABLED=false|
      s|AIRGEDDON_WINDOWS_HANDLING=xterm|AIRGEDDON_WINDOWS_HANDLING=tmux|
    ' .airgeddonrc

    # Modify the script to use a writable directory for runtime files
    sed -i 's|scriptfolder=".*"|scriptfolder="$HOME/.config/airgeddon"|' airgeddon.sh
    sed -i 's|language_strings_file=".*"|language_strings_file="$scriptfolder/language_strings.sh"|' airgeddon.sh
    sed -i 's|saved_arc_path=".*"|saved_arc_path="$scriptfolder/.airgeddonrc"|' airgeddon.sh
    sed -i 's|plugins_dir=".*"|plugins_dir="$scriptfolder/plugins"|' airgeddon.sh

    # Ensure the script creates the necessary directory and copies files if they don't exist
    cat <<EOF >> airgeddon.sh
    
    # Create config directory and copy necessary files
    mkdir -p "\$HOME/.config/airgeddon/plugins"
    for file in .airgeddonrc language_strings.sh known_pins.db; do
      if [ ! -f "\$HOME/.config/airgeddon/\$file" ]; then
        cp "${placeholder "out"}/share/airgeddon/\$file" "\$HOME/.config/airgeddon/"
      fi
    done
    if [ -z "\$(ls -A "\$HOME/.config/airgeddon/plugins")" ]; then
      cp -r "${placeholder "out"}/share/airgeddon/plugins/"* "\$HOME/.config/airgeddon/plugins/"
    fi
    EOF
  '';

  installPhase = ''
    runHook preInstall

    install -Dm 755 airgeddon.sh "$out/bin/airgeddon"
    install -dm 755 "$out/share/airgeddon"
    
    # Copy necessary files to the output directory
    cp -r .airgeddonrc known_pins.db language_strings.sh plugins "$out/share/airgeddon/"
    
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/airgeddon \
      --prefix PATH : ${lib.makeBinPath deps}
  '';

  meta = with lib; {
    description = "A TUI multi-use bash script for Linux systems to audit wireless networks";
    homepage = "https://github.com/v1s1t0r1sh3r3/airgeddon";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ offline ];
    platforms = platforms.linux;
  };
}