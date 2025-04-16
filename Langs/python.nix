{ pkgs, ... }:

{
  pythonpackages = with pkgs; [

    opencv
    ffmpeg-full


    #-> Python
    (python312.withPackages (pk: with pk; [

    # (callPackage ../Programs/Packages/unsloth.nix {})
    # (callPackage ../Programs/Packages/flash-attn.nix {})
    (callPackage ../Programs/Packages/smolagents.nix {})

    # (callPackage ../Programs/Packages/openinference-instrumentation-smolagents.nix {})


        #-> Basics
        uv
        pip
        pylint
        pylance
        setuptools
        python-dotenv
        terminaltables

            #-> GUI
            pyqt6
            pyside6
            pyqt6-sip
            pyqt6-charts
            pyqt6-webengine

            #-> Juniper/jupter
            notebook
            ipywidgets
            jupyterlab

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

        diffusers
        transformers


        #-> Cuda
        numba
        pycuda


        #-> torch
        # jax
        torch-bin
        triton-bin
        torchaudio-bin
        torchvision-bin

        #-> Open telemetry
        opentelemetry-sdk
        opentelemetry-exporter-otlp

        #-> Ai
        nltk
        datasets
        evaluate
        langchain
        langchain-community
        sentence-transformers

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
          huggingface-hub
          # google-cloud-texttospeech

          #> speechrecognition
          soundfile
          # realtime-stt
          # arabic-reshaper


        ]
      )
    )
  ]
  # ++ customPythonPackages
  ;

  python-nixpkgs-extensions = with pkgs.vscode-extensions; [
    #* Python
    ms-python.python
    ms-python.debugpy
    # ms-pyright.pyright
    # charliermarsh.ruff
    ms-python.vscode-pylance

      #->Jupyter
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-toolsai.jupyter-renderers
      ms-toolsai.vscode-jupyter-slideshow
      ms-toolsai.vscode-jupyter-cell-tags

  ];

  python-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
    {
      #https://open-vsx.org/extension/KevinRose/vsc-python-indent
      name = "vsc-python-indent";
      publisher = "KevinRose";
      version = "1.18.0";
      hash = "sha256-hiOMcHiW8KFmau7WYli0pFszBBkb6HphZsz+QT5vHv0=";
    }
    {
      #https://marketplace.visualstudio.com/items?itemName=ms-python.pylint
      name = "pylint";
      publisher = "ms-python";
      version = "2023.11.13481007";  # Check for the latest version
      hash = "sha256-rn+6vT1ZNpjzHwIy6ACkWVvQVCEUWG2abCoirkkpJts=";
    }
  ];
}