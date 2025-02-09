{
  lib,
  fetchFromGitHub,
  iproute2,
  nftables,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "Evillimiter";
  version = "1.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Masrkai";
    repo = "Evillimiter";
    tag = "v${version}";
    hash = "sha256-g7OZLAzH47RrqvnEQC+ExsGxiRlVvRlihct8ltGVlOY=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    tqdm
    scapy
    netaddr
    colorama
    iproute2
    nftables
    netifaces
    setuptools
    terminaltables
  ];

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
    mainProgram = "Evillimiter";
  };
}