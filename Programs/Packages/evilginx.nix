{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "evilginx2";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "kgretzky";
    repo = "evilginx2";
    rev = "v${version}";
    sha256 = "sha256-PXWROzd0Ow3tl0+jHD1PozpN6mbD2lskCTAIQyd50qQ=";  # replace with actual sha256 of the source
  };

  # Use the vendored dependencies provided in the repo
  vendorHash = null;

  # Meta attributes (evilginx2 is BSD-3-Clause licensed)
  meta = with lib; {
    description = "Standalone man-in-the-middle framework for phishing login credentials";
    homepage = "https://github.com/kgretzky/evilginx2";
    license = licenses.bsd3;
    # maintainers = with maintainers; [ ];  # add a maintainer if desired
  };
}
