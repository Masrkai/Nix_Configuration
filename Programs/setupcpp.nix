{ pkgs }:

  pkgs.writeScriptBin  "setupcpp" ''
    #!/${pkgs.bash}/bin/bash
    ${pkgs.bash}/bin/bash ${./setupcpp.sh}
  ''