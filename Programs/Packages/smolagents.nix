
{
  lib
, pkgs

  #! build-system
, setuptools
, python3Packages

}:


let
  pname = "smolagents";
  version = "1.9.2";
in

  python3Packages.buildPythonPackage {
  inherit pname version;
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "huggingface";
    repo = "smolagents";
    rev = "v${version}";
    hash = "sha256-YAN9MN3I7LMzuhr/069klbHbYZ+hFZG1MHoWxuwOxcE=";
  };

  nativeBuildInputs = with python3Packages; [
    wheel
    setuptools
    accelerate
    pythonRelaxDepsHook
  ];

  # List of packages for which to relax dependency restrictions.
  pythonRelaxDeps = [
    "rich"
    "gradio"
    "markdownify"
    "duckduckgo-search"
    "e2b-code-interpreter"
  ];

  propagatedBuildInputs = with python3Packages; [
    huggingface-hub
    requests
    rich
    pandas
    jinja2
    pillow
    markdownify
    duckduckgo-search
    python-dotenv
    transformers
    gradio
    # e2b-code-interpreter # Not yet available in nixpkgs
    openai
    torch-bin
    triton-bin
    accelerate
    torchvision-bin
  ];

  pythonImportsCheck = [ "smolagents" "huggingface_hub"];

  meta = with lib; {
    homepage = "https://huggingface.co/docs/smolagents/index";
    description = ''
      🤗 smolagents: a barebones library for agents. Agents write python code to
      call tools or orchestrate other agents.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ offline ];
  };
}