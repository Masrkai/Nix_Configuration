{ lib, ...}:

{
  environment.shellAliases = {
    "python312-shell" = "nix-shell /etc/nixos/dev-shells/python312-shell.nix";
    "python310-shell" = "nix-shell /etc/nixos/dev-shells/python310-shell.nix";
  };
}
