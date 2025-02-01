let
  secrets = import ../Sec/secrets.nix;
in
{
  image = "ghcr.io/open-webui/open-webui:ollama";

  environment = {
    "TZ" = secrets.TZ;
    "OLLAMA_API_BASE_URL" = "http://127.0.0.1:11434/api";
    "OLLAMA_BASE_URL" = "http://127.0.0.1:11434";
  };

  volumes = [
    "${builtins.getEnv "HOME"}/open-webui/data:/app/backend/data"
  ];

  ports = ["127.0.0.1:3000:8080"];

  extraOptions = [
    "--pull=newer"           # Pull if the image on the registry is newer
    "--network=host"
    "--name=open-webui"
    "--hostname=open-webui"
    "--add-host=host.containers.internal:host-gateway"
  ];
}