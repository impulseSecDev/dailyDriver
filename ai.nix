{config, pkgs, lib, ...}:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    port = 11434;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VWERSION = "10.3.0";
      OLLAMA_FLASH_ATTENTION="False";
      OLLAMA_KV_CACHE_TYPE="f16";
    };
  };

  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      WEBUI_AUTH = "True";
      TF_FORCE_GPU_ALLOW_GROWTH = "True";
      CUDA_VISIBLE_DEVICES = "0";
    };
  };
}
