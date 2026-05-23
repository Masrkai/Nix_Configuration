{ lib
, python3
, fetchurl
, git
, nodejs_22
, ripgrep
, ffmpeg
, makeWrapper
}:

python3.pkgs.buildPythonPackage rec {
  pname = "hermes-agent";
  version = "0.14.0";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/22/ae/5c7259fcc124b2753d4811527e21bebef066a209fbf1496ab47f544b9919/hermes_agent-0.14.0-py3-none-any.whl";
    hash = "sha256-Z9eb12H4RqfoS4sb5v34vDjniTV89/T0dN4WXpzhc5w=";
  };

  # # pypaInstallPhase looks for the wheel in a dist/ directory
  # preUnpack = ''
  #   mkdir -p dist
  #   cp $src dist/hermes_agent-${version}-py3-none-any.whl
  # '';

  # The wheel is already built; skip build
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    for bin in hermes hermes-agent hermes-acp; do
      if [ -f "$out/bin/$bin" ]; then
        wrapProgram "$out/bin/$bin" \
          --prefix PATH : ${lib.makeBinPath [ git nodejs_22 ripgrep ffmpeg ]}
      fi
    done
  '';

  meta = with lib; {
    description = "Self-improving AI agent by Nous Research";
    homepage    = "https://hermes-agent.nousresearch.com";
    license     = licenses.mit;
    platforms   = platforms.linux ++ platforms.darwin;
    mainProgram = "hermes";
  };
}