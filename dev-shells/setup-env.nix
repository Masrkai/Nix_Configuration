{ config, lib, pkgs, modulesPath, ... }:

{

  setupEnvScript = pkgs.writeTextFile {
    name = "setup-env";
    destination = "/bin/setup-env";
    text = builtins.readFile ./setup-env.sh;
    executable = true;
    checkPhase = ''
      ${pkgs.bash}/bin/bash -n $out/bin/setup-env
    '';
  };

}

