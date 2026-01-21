{ pkgs, ... }:

let
  unstable = import <unstable> {
    config.allowUnfree = true;
    # config.allowBroken = true;
    };



in

{

   environment.systemPackages = with pkgs; [

    opencv
    # llama-cpp
    ffmpeg-full
    unstable.ruff

    honcho
    chromedriver
    geckodriver
    (lib.lowPrio (python312.withPackages (ps: with ps; [

        # # unsloth
        # # unsloth-zoo
        # smolagents
        #   duckduckgo-search


        jax

        #-> Basics
        uv
        pip

        #-> Networks
        netutils

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
            piexif
            onnxruntime

            qrcode
            qrcode-terminal

            #-> cryptography & Databases
            pandas
            sqlite
            pymysql
            portalocker
            cryptography

        ]
      )
    )
    )

   ];
}