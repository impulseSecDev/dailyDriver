{ config, pkgs, lib, ... }:
{
  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      WEBUI_AUTH = "True";
      WEBUI_URL = "https://gpt.mesh.loranjennings.com";
      #CORS_ALLOW_ORIGIN = "https://gpt.mesh.loranjennings.com;http://127.0.0.1:8080;http://localhost:8080";
      ENABLE_OLLAMA_API = "False";
      ENABLE_WEBSOCKET_SUPPORT = "True";
      DEVICE_TYPE = "cpu";
      AIOHTTP_CLIENT_TIMEOUT = "600";
      UVICORN_WORKERS = "1";
      WEBSOCKET_PING_INTERVAL = "10";
      WEBSOCKET_PING_TIMEOUT = "60";
      FRONTEND_BUILD_DIR = "/var/lib/open-webui/build";
      DATA_DIR = "/var/lib/open-webui/data";
      STATIC_DIR = "/var/lib/open-webui/static";
    };
  };

  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-vulkan;
    settings = {
      host = "127.1.0.1";
      port = 8080;
      models-dir = "/var/lib/models/";
      models-max = 1;
      models-preset = pkgs.writeText "llama-presets.ini" ''
        [*]
        n-gpu-layers = 99
        parallel = 1
        ctx-size = 65536
        flash-attn = on
        cache-type-k = q8_0
        cache-type-v = q4_0
        batch-size = 2048
        ubatch-size = 512
        jinja = true
        no-reasoning-preserve = true

        [Swift-1.5-Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp]
        spec-type = draft-mtp
        spec-draft-n-max = 3
      '';
    };
  };

  systemd.services.llama-cpp.serviceConfig = {
    CacheDirectory = "llama-cpp";
    Environment = "XDG_CACHE_HOME=/var/cache/llama-cpp";
  };
}

