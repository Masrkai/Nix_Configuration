{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
    go              # Go compiler/toolchain
    delve           # Debugger
    gofumpt         # Formatter
    gopls           # Language Server (LSP)

    # golangci-lint
    # go-outline
   ];
}
