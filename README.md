# My NixOS Configuration ❄️

![NixOS](https://img.shields.io/badge/-NixOS-5277C3?style=flat-square&logo=nixos&logoColor=black) ![Nix](https://img.shields.io/badge/-Nix-7EBAFF?style=flat-square&logo=nixos&logoColor=black)

This is a very specialized configuration, I really put my heart into over 2 years to have redundancy for my system because this is the whole point of NixOS in the first place

- I have been learning Nix since 2023 until the last update of this configuration, I am no expert like some others maybe are so take my choices with a grain of salt

- Reviewed README on 01/08/2025 in DD/MM/YYYY

## Programming languages support:
  Primarily I use VScode, so In configuration I added support for:
  - C++
  - Rust
  - python
  - SQL / MySQL server
  - jupyter notebooks / server

  with development shells for:
  - Python
  - JavaScript

## AI workflow
here you will find almost all AI libraries you may need.
from sci-kit learn (sklearn) to pytorch (using torch-bin), transformers, langchain, smolagents, flash-attn, streamlit, gradio and more !

it's mostly python libraries so check the [/Langs/python.nix](https://github.com/Masrkai/Nix_Configuration/tree/main/Langs/python.nix "python_specifci_configuration") file

## Configuration Schematic
1. Programs and my own hand made things are in [/Programs](https://github.com/Masrkai/Nix_Configuration/tree/main/Programs "Programs") which currently include:

Using python:
* [CTJ](https://github.com/Masrkai/Nix_Configuration/blob/main/Programs/ctj.py "CTJ") "Current *images* To JPEG"
* [MD-PDF](https://github.com/Masrkai/Nix_Configuration/blob/main/Programs/MD-PDF.py "MD-PDF.py") "Converts markdown files to PDF"

Using bash:
* [Backup](https://github.com/Masrkai/Nix_Configuration/blob/main/Programs/backup.sh "backup.sh") "*What alllows me to publish my configuration on Github*"
* [Setupcpp](https://github.com/Masrkai/Nix_Configuration/blob/main/Programs/setupcpp.sh "setupcpp.sh") "Sets up a C++ Project"

2. And there are some handy security configuration in [security.nix](https://github.com/Masrkai/Nix_Configuration/blob/main/security.nix "security.nix") which currently include:

* Kernel parameters
* Banned file formats
* Disabling of CUPS service

## I Have More!

_It's too long to document but i am going to soon_
