let
  secrets = import ../Sec/secrets.nix;
in
{
  image = "ghcr.io/open-webui/open-webui:ollama";

  environment = {
    "TZ" = secrets.TZ;

    "OLLAMA_BASE_URL" = "http://127.0.0.1:11434";
    "OLLAMA_API_BASE_URL" = "http://127.0.0.1:11434/api";

    "DO_NOT_TRACK" = "True";
    "SCARF_NO_ANALYTICS" = "True";
    "ANONYMIZED_TELEMETRY" = "False";

    "ENABLE_RAG_WEB_SEARCH" = "True";
    "RAG_WEB_SEARCH_ENGINE" = "searxng";
    "RAG_WEB_SEARCH_RESULT_COUNT" = "4";
    "RAG_WEB_SEARCH_CONCURRENT_REQUESTS" = "12";

    "SEARXNG_QUERY_URL" = "http://searxng:8888/search?q=<query>";
  };

  volumes = [
    "${builtins.getEnv "HOME"}/open-webui/data:/app/backend/data"
  ];

  ports = ["127.0.0.1:3000:8080"];

  extraOptions = [
    "--gpus=all"
    "--pull=newer"
    "--network=host"
    "--name=open-webui"
    "--hostname=open-webui"
    "--add-host=host.containers.internal:host-gateway"
  ];
}