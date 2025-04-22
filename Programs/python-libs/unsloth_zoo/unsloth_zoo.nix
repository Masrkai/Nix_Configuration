{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,
  setuptools-scm,

  accelerate,
  cut-cross-entropy,
  datasets,
  hf-transfer,
  huggingface-hub,
  packaging,
  peft,
  psutil,
  sentencepiece,
  torch,
  tqdm,
  transformers,
  trl,
  tyro,
}:

buildPythonPackage rec {
  pname = "unsloth-zoo";
  version = "2025-02-v2";
  pyproject = true;

  src = fetchFromGitHub {
    repo = "unsloth-zoo";
    owner = "unslothai";
    rev = "31fce522e291e95c3829dc8cc8ac29e03e6c0580";
    hash = "sha256-GGh5B1JF+Q0nRhpUqq7EkwN8X55dUtcZ1/9nmyYpmfQ=";
  };

  # pyproject.toml requires an obsolete version of protobuf,
  # but it is not used.
  # Upstream issue: https://github.com/unslothai/unsloth-zoo/pull/68
  pythonRelaxDeps = [
    "protobuf"
  ];

  patches = [
    # Avoid circular dependency in Nix, since `unsloth` depends on `unsloth-zoo`.
    ./dont-require-unsloth.patch
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    accelerate
    cut-cross-entropy
    datasets
    hf-transfer
    huggingface-hub
    packaging
    peft
    psutil
    sentencepiece
    torch
    tqdm
    transformers
    trl
    tyro
  ];

  # Note: The source repository contains no test
  doCheck = false;

  pythonImportsCheck = [
    "unsloth_zoo"
  ];

  meta = {
    description = "Utils for Unsloth";
    homepage = "https://github.com/unslothai/unsloth_zoo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hoh ];
  };
}