{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonRelaxDepsHook
, setuptools
, transformers
, requests
, rich
, pandas
, jinja2
, markdownify
, gradio
, duckduckgo-search
, python-dotenv
, e2b-code-interpreter
, torch-bin
, torchvision-bin
, accelerate
, openai
}:

let
  pname = "smolagents";
  version = "1.9.2";
in buildPythonPackage {
  inherit pname version;

  format = "pyproject";  # More precise than just setting pyproject = true

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "smolagents";
    rev = "v${version}";
    hash = "";  # Replace with actual hash
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
    setuptools
  ];

  propagatedBuildInputs = [
    rich
    pandas
    jinja2
    gradio
    requests
    markdownify
    transformers
    duckduckgo-search
    python-dotenv
    e2b-code-interpreter

    torch-bin
    torchvision-bin

    openai
    accelerate
  ];

  pythonRelaxDeps = [
    "rich"
    "gradio"
    "markdownify"
    "duckduckgo-search"
    "e2b-code-interpreter"
  ];

  pythonImportsCheck = [ "smolagents" ];

  meta = with lib; {
    homepage = "https://huggingface.co/docs/smolagents/index";
    description = ''
      A barebones library for agents. Agents write python code to
      call tools and orchestrate other agents
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ offline ];
  };
}