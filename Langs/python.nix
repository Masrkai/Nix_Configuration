{ pkgs, ... }:

let
  unstable = import <unstable> {
    config.allowUnfree = true;
    # config.allowBroken = true;
    };



in

{
  pythonpackages = with pkgs; [

    opencv
    llama-cpp
    ffmpeg-full
    unstable.ruff

    (python312.withPackages (ps: with ps; [

        unsloth
        smolagents
          duckduckgo-search
        unsloth-zoo

        #-> Basics
        uv
        pip

        pylint
        # pylance

        pathlib2
        setuptools
        python-dotenv
        terminaltables

            #-> Nvidia Cuda
            pynvml
            numba
            pycuda

            #-> GUI
            pyqt6
            pyside6
            pyqt6-sip
            pyqt6-charts
            pyqt6-webengine

            screeninfo
            raylib-python-cffi


            #-> Juniper/jupter
            notebook
            nbformat
            ipynbname
            ipywidgets

            #-> IpyKernal
            ipython
            ipykernel
            ipython-sql
            ipython-genutils

            #> Packaging \ Compiling
            pyinstaller
            pyinstaller-versionfile

            #-> Misc
            geopy
            selenium

            pillow

            qrcode
            qrcode-terminal

            #-> cryptography & Databases
            pandas
            sqlite
            pymysql
            portalocker
            cryptography

        #-> Web Scraping
        beautifulsoup4
        types-beautifulsoup4

        #-> RPC
        grpcio
        grpcio-tools

        h5py
        lxml
        tqdm
        scapy
        curio
        numpy
        # cupy
        pyvips
        netaddr
        seaborn

        #-> DB
        mysql-connector

        #-> Algos
        opencv
        openusd

        networkx
        openpyxl
        requests
        colorama
        netifaces
        markdown2
        matplotlib
        weasyprint
        markdown-it-py

        optimum
        diffusers
        transformers


        #-> torch
        torch
        # triton
        # torchaudio
        # torchvision

        #-> Open telemetry
        opentelemetry-sdk
        opentelemetry-exporter-otlp

        #-> Ai
        nltk
        # vllm
        # flash-attn
        pypdf2
        datasets
        evaluate
        langchain
        langchain-community
        # sentence-transformers

          #-> Ollama
          ollama
            #! Ollama integration
            langchain-ollama
            llama-index-llms-ollama
            llama-index-embeddings-ollama

          #-> ML
          peft
          bitsandbytes
          scikit-learn
          scikit-image

          #> UI
          pydub
          gradio
           gradio-pdf
           gradio-client
          streamlit

          #> Platforms
          openai
          replicate
          huggingface-hub
          # google-cloud-texttospeech

          #> speechrecognition
          soundfile
          # realtime-stt
          # arabic-reshaper


        ]
      )
    )
  ];

  python-nixpkgs-extensions = with pkgs.vscode-extensions; [
    #* Python
    ms-python.python
    ms-python.debugpy
    charliermarsh.ruff

      #->Jupyter
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-toolsai.jupyter-renderers
      ms-toolsai.vscode-jupyter-slideshow
      ms-toolsai.vscode-jupyter-cell-tags

  ];

  python-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
    # {
    #   #https://open-vsx.org/extension/KevinRose/vsc-python-indent
    #   name = "vsc-python-indent";
    #   publisher = "KevinRose";
    #   version = "1.18.0";
    #   hash = "sha256-hiOMcHiW8KFmau7WYli0pFszBBkb6HphZsz+QT5vHv0=";
    # }
    # {
    #   #https://marketplace.visualstudio.com/items?itemName=ms-python.pylint
    #   name = "pylint";
    #   publisher = "ms-python";
    #   version = "2023.11.13481007";  # Check for the latest version
    #   hash = "sha256-rn+6vT1ZNpjzHwIy6ACkWVvQVCEUWG2abCoirkkpJts=";
    # }
  ];
}