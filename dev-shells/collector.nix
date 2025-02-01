{ lib, ...}:

{
  environment.shellAliases = {
    "python-shell" = "nix-shell --command bash /etc/nixos/dev-shells/python-shell.nix";
    "js-shell" = "nix-shell --command bash  /etc/nixos/dev-shells/js-shell.nix";
  };
}
