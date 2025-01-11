{ lib, ...}:

{
  environment.shellAliases = {
    "python-shell" = "nix-shell /etc/nixos/dev-shells/python-shell.nix";
  };
}
