{ pkgs, ... }:

let

customPackages = {
    #? Python
    # ctj = pkgs.callPackage ./Programs/custom/ctj.nix {};
    # MD-PDF = pkgs.callPackage ./Programs/custom/MD-PDF.nix {};
    smolagents = pkgs.callPackage ../Programs/custom/smolagents.nix {};
    # evillimiter = pkgs.callPackage ./Programs/Packages/evillimiter.nix {};
    # mac-formatter = pkgs.callPackage ../Programs/custom/mac-formatter.nix {};

  };
in
{
  pythonpackages = with pkgs; [

    # customPackages.smolagents

    opencv
    ffmpeg-full

    #-> Python
    (python312.withPackages (pk: with pk; [
        #-> Basics
        uv
        pip
        pylint
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
            jupyterlab

            #-> IpyKernal
            ipykernel
            ipython-sql
            ipython-genutils

            #> Packaging \ Compiling
            pyinstaller
            pyinstaller-versionfile

            #-> Misc
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

        #-> ML
        scikit-learn
        scikit-image

        h5py
        lxml
        tqdm
        scapy
        curio
        numpy
        pyvips
        netaddr


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

        # diffusers
        # transformers


        #-> torch
        torch-bin
        triton-bin
        torchaudio-bin
        torchvision-bin

        #-> Ai
        nltk
        datasets
        # speechbrain
        # opencv-python

        # jax
        # torchWithCuda
        # tensorflow-bin

          #> UI
          pydub
          # gradio

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
  ];

  python-nixpkgs-extensions = with pkgs.vscode-extensions; [
    #* Python
    ms-python.python
    ms-python.debugpy
    charliermarsh.ruff
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