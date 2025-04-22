{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  unsloth,
  flash-attn,
  ninja,
  packaging,
  bitsandbytes,
  datasets,
  hf-transfer,
  huggingface-hub,
  numpy,
  protobuf,
  psutil,
  sentencepiece,
  tqdm,
  transformers,
  tyro,
  unsloth-zoo,
  wheel,
  accelerate,
  peft,
  torch,
  trl,
  xformers,
}:

buildPythonPackage rec {
  pname = "unsloth";
  version = "2025-02-v2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "unslothai";
    repo = "unsloth";
    # rev = "November-2024";
    hash =
    lib.fakeHash
    # "sha256-Xc2PSVCwfsG2mNwF/aLHSpWkSetHdX3fySQr+DljDNI="
    ;
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ numpy torch ];

  optional-dependencies = {
    colab = [
      unsloth
    ];
    colab-ampere = [
      flash-attn
      ninja
      packaging
      unsloth
    ];
    colab-ampere-torch211 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    colab-ampere-torch220 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    colab-new = [
      bitsandbytes
      datasets
      hf-transfer
      huggingface-hub
      numpy
      packaging
      protobuf
      psutil
      sentencepiece
      tqdm
      transformers
      tyro
      unsloth-zoo
      wheel
    ];
    colab-no-deps = [
      accelerate
      bitsandbytes
      peft
      protobuf
      trl
      xformers
    ];
    colab-torch211 = [
      bitsandbytes
      unsloth
    ];
    colab-torch220 = [
      bitsandbytes
      unsloth
    ];
    conda = [
      unsloth
    ];
    cu118 = [
      bitsandbytes
      unsloth
    ];
    cu118-ampere = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu118-ampere-torch211 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu118-ampere-torch220 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu118-ampere-torch230 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu118-ampere-torch240 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu118-torch211 = [
      bitsandbytes
      unsloth
    ];
    cu118-torch212 = [
      bitsandbytes
      unsloth
    ];
    cu118-torch220 = [
      bitsandbytes
      unsloth
    ];
    cu118-torch230 = [
      bitsandbytes
      unsloth
    ];
    cu118-torch240 = [
      bitsandbytes
      unsloth
    ];
    cu118only = [
      xformers
    ];
    cu118onlytorch211 = [
      xformers
    ];
    cu118onlytorch212 = [
      xformers
    ];
    cu118onlytorch220 = [
      xformers
    ];
    cu118onlytorch230 = [
      xformers
    ];
    cu118onlytorch240 = [
      xformers
    ];
    cu121 = [
      bitsandbytes
      unsloth
    ];
    cu121-ampere = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu121-ampere-torch211 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu121-ampere-torch220 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu121-ampere-torch230 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu121-ampere-torch240 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu121-ampere-torch250 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu121-torch211 = [
      bitsandbytes
      unsloth
    ];
    cu121-torch212 = [
      bitsandbytes
      unsloth
    ];
    cu121-torch220 = [
      bitsandbytes
      unsloth
    ];
    cu121-torch230 = [
      bitsandbytes
      unsloth
    ];
    cu121-torch240 = [
      bitsandbytes
      unsloth
    ];
    cu121-torch250 = [
      bitsandbytes
      unsloth
    ];
    cu121only = [
      xformers
    ];
    cu121onlytorch211 = [
      xformers
    ];
    cu121onlytorch212 = [
      xformers
    ];
    cu121onlytorch220 = [
      xformers
    ];
    cu121onlytorch230 = [
      xformers
    ];
    cu121onlytorch240 = [
      xformers
    ];
    cu121onlytorch250 = [
      xformers
    ];
    cu124-ampere-torch240 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu124-ampere-torch250 = [
      bitsandbytes
      flash-attn
      ninja
      packaging
      unsloth
    ];
    cu124-torch240 = [
      bitsandbytes
      unsloth
    ];
    cu124-torch250 = [
      bitsandbytes
      unsloth
    ];
    cu124onlytorch240 = [
      xformers
    ];
    cu124onlytorch250 = [
      xformers
    ];
    huggingface = [
      accelerate
      datasets
      hf-transfer
      huggingface-hub
      numpy
      packaging
      peft
      protobuf
      psutil
      sentencepiece
      tqdm
      transformers
      trl
      tyro
      unsloth-zoo
      wheel
    ];
    kaggle = [
      unsloth
    ];
    kaggle-new = [
      bitsandbytes
      unsloth
    ];
  };

  pythonImportsCheck = [
    # Requires GPU access
    # "unsloth"
  ];

  meta = {
    description = "Finetune Llama 3.2, Mistral, Phi, Qwen 2.5 & Gemma LLMs 2-5x faster with 80% less memory";
    homepage = "https://github.com/unslothai/unsloth/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}