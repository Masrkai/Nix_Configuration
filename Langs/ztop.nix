{  lib, pkgs, ...}:
{



  imports = [
    ./env.nix
    ./vscodium.nix
    ./sql-server.nix
  ];

  nixpkgs = {
    overlays = [
      (final: prev: {
        # Top-level package replacements
        torch = prev.torch-bin;
        triton = prev.triton-bin;
        torchaudio = prev.torchaudio-bin;
        torchvision = prev.torchvision-bin;

        pythonPackagesExtensions = [

          (py-final: py-prev: {
            torch = py-final.torch-bin;
            triton = py-final.triton-bin;
            torchaudio = py-final.torchaudio-bin;
            torchvision = py-final.torchvision-bin;
          })
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        # Compositionally correct extension for huggingface-hub
        (py-final: py-prev: let
          version = "0.29.1";
        in {
          huggingface-hub = py-prev.huggingface-hub.overrideAttrs (oldAttrs: {
            inherit version;
            src = prev.fetchFromGitHub {  # Use prev from outer scope
              owner = "huggingface";
              repo = "huggingface_hub";
              tag = "v${version}";
              # hash = lib.fakeHash;
              hash = "sha256-9G5oq8X5/MtHZAOM7QHoMyRePPFwMe4Wa66y+japxwA=";
            };
            meta = oldAttrs.meta // {
              changelog = "https://github.com/huggingface/huggingface_hub/releases/tag/v${version}";
            };
          });
        })

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ];


      })
    ];
  };





}