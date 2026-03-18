{
  lib,
  fetchFromGitHub,
  iproute2,
  nftables,
  python3Packages,
  makeWrapper,
}:

python3Packages.buildPythonApplication rec {
  pname = "evillimiter";
  version = "1.7.5";
  format = "other";

  src = fetchFromGitHub {
    owner = "Masrkai";
    repo = "Evillimiter";
    tag = "1.7.5";
    hash = "sha256-BEFvtHFsoI9ampG/CidpxIBLO1Md/IjIQj4L7/h8LOg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    tqdm
    scapy
    netaddr
    colorama
    netifaces
    terminaltables
    setuptools
  ] ++ [
    iproute2
    nftables
  ];

  # No build phase needed since we're not using setup.py
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Create the target directory
    mkdir -p $out/lib/python${python3Packages.python.pythonVersion}/site-packages/evillimiter
    
    # Copy the entire evillimiter directory
    cp -r evillimiter/* $out/lib/python${python3Packages.python.pythonVersion}/site-packages/evillimiter/
    
    # Create bin directory and wrapper script
    mkdir -p $out/bin
    
    # Create the main executable wrapper
    makeWrapper ${python3Packages.python}/bin/python $out/bin/evillimiter \
      --add-flags "$out/lib/python${python3Packages.python.pythonVersion}/site-packages/evillimiter/evillimiter.py" \
      --prefix PATH : ${lib.makeBinPath [ iproute2 nftables ]} \
      --set PYTHONPATH "$out/lib/python${python3Packages.python.pythonVersion}/site-packages:$PYTHONPATH"

    runHook postInstall
  '';

  # Project has no tests
  doCheck = false;

  meta = with lib; {
    description = "Tool that monitors, analyzes and limits the bandwidth";
    longDescription = ''
      A tool to monitor, analyze and limit the bandwidth (upload/download) of
      devices on your local network without physical or administrative access.
      evillimiter employs ARP spoofing and traffic shaping to throttle the
      bandwidth of hosts on the network.
    '';
    homepage = "https://github.com/Masrkai/Evillimiter";
    license = licenses.mit;
    maintainers = with maintainers; [ offline ];
    mainProgram = "evillimiter";
    platforms = platforms.linux;
  };
}