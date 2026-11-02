{config, pkgs, lib, ...}:
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
      TF_FORCE_GPU_ALLOW_GROWTH = "True";
      FRONTEND_BUILD_DIR = "/var/lib/open-webui/build";
      DATA_DIR = "/var/lib/open-webui/data";
      STATIC_DIR = "/var/lib/open-webui/static";
    };
  };

  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    host = "127.1.0.1";
    port = 8080;
    modelsDir = "/var/lib/models/";
    extraFlags = [
      "-ngl" "99" # Offloads 99 model layers to GPU VRAM
      "-c" "114688" # Sets initial context window memory limit -  65536 is a good target but 40960 is the usual sweet spot on 16gb vram 
      "-fa" "on" # Enables Flash Attention to reduce VRAM usage and speed up prompt ingestion
      "-ctk" "q4_0" # Quantizes Key memory cache to 8-bit (cuts KV cache VRAM footprint in half with no loss in accuracy)
      "-ctv" "q4_0" # Quantizes Value memory cache to 8-bit (cuts KV cache VRAM footprint in half with no loss in accuracy)
      "--context-shift" #prevents out of memory errors with longer conversations
      "--jinja" # Required for models to handle tool calling
      # # --- Multi-Token Prediction (MTP) Flags --- Cames at expense of reduced context allowance just for slightly faster responses
      # "--spec-type" "draft-mtp"          # Sets speculative decoding to MTP mode
      # "--spec-draft-n-max" "3"     # Predict up to 3 draft tokens per step
    ];
  };
}
