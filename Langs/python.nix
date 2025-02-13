{ pkgs, ... }:

{
  pythonpackages = with pkgs; [
    #-> Python
    (python312.withPackages (pk: with pk; [
        #-> Basics
        uv
        pip
        pylint
        python-dotenv
        terminaltables

            #-> GUI
            pyqt6
            pyqt6-sip
            pyqt6-charts
            pyqt6-webengine

            #-> Juniper/jupter
            notebook
            jupyterlab

            ipykernel
            ipython-sql
            ipython-genutils

            #> Packaging \ Compiling
            pyinstaller
            pyinstaller-versionfile


        h5py
        lxml
        tqdm
        scapy
        curio
        numpy
        pandas
        pyvips
        sqlite
        netaddr
        openusd
        networkx
        openpyxl
        requests
        colorama
        netifaces
        markdown2
        matplotlib
        weasyprint
        setuptools
        markdown-it-py

        #-> Ai
        nltk
        # pydub
        datasets
        # speechbrain
        # transformers
        # opencv-python

        # jax
        # torchWithCuda
        # tensorflow-bin

          #> UI
          # gradio
          # streamlit

          #> Platforms
          # openai
          huggingface-hub
          # google-cloud-texttospeech

          #> speechrecognition
          soundfile
          # realtime-stt
          # arabic-reshaper


        beautifulsoup4
        types-beautifulsoup4
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