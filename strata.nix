# strata.nix
{ config, pkgs, lib, inputs, ... }:
let
  rp = pkgs.rocmPackages;

  # Edit these
  host = "127.2.0.1";
  port = 8080;
  stateDir = "/var/lib/strata";
  modelDir = "${stateDir}/models";
  modelPrefix = "Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS";

  rocm = pkgs.symlinkJoin {
    name = "rocm-merged";
    paths = with rp; [
      clr
      hipblas
      hipblas-common
      rocblas
      rocm-device-libs
      rocm-comgr
      rocm-runtime
    ];
  };

  hipEnv = {
    ROCM_PATH = "${rocm}";
    HIP_PATH = "${rocm}";
    HIP_DEVICE_LIB_PATH = "${rp.rocm-device-libs}/amdgcn/bitcode";
  };

  # --- Engine binary ---
  strata = pkgs.stdenv.mkDerivation ({
    pname = "strata-gfx1030";
    version = "git-${inputs.strata-src.shortRev or "dirty"}";
    src = inputs.strata-src;

    nativeBuildInputs = with pkgs; [ cmake ninja git python3 ];
    buildInputs = [ rocm ];

    # Phases are written out by hand, so the cmake/ninja hooks must stay out of the way
    dontUseCmakeConfigure = true;
    dontUseNinjaBuild = true;
    dontUseNinjaCheck = true;
    dontUseNinjaInstall = true;

    configurePhase = ''
      runHook preConfigure

      # llama.cpp must be the exact revision Strata pins, and writable
      cp -r ${inputs.llama-src} $TMPDIR/llama
      chmod -R u+w $TMPDIR/llama

      cmake -S . -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_PREFIX_PATH=${rocm} \
        -DSTRATA_ENABLE_HIP=ON \
        -DSTRATA_ENABLE_CUDA=OFF \
        -DCMAKE_HIP_ARCHITECTURES=gfx1030 \
        -DCMAKE_HIP_COMPILER=${rp.llvm.clang}/bin/clang++ \
        -DSTRATA_GGML_DIR=$TMPDIR/llama \
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      cmake --build build --target strata -j $NIX_BUILD_CORES
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      bin=$(find build -maxdepth 2 -name strata -type f -perm -u+x | head -n1)
      test -n "$bin" || { echo "strata binary not found"; find build -maxdepth 2 -type f -perm -u+x; exit 1; }
      install -Dm755 "$bin" $out/bin/strata
      runHook postInstall
    '';
  } // hipEnv);

  strataPython = pkgs.python3.withPackages (ps: with ps; [
    jinja2
    numpy
    pillow
    psutil
    pyyaml
    regex
    requests
    tqdm
    textual
  ]);

  # --- Server config ---
  serverConfig = pkgs.writeText "strata-hip.json" (builtins.toJSON {
    exe = "${strata}/bin/strata";
    args = [
      "--pack" "packs/iq3xxs"
      "--native" "${modelDir}/${modelPrefix}-00001-of-00002.gguf"
      "--ple-gguf" "${modelDir}/${modelPrefix}-00002-of-00002.gguf"
      "--mmap-experts" "--expert-profile" "data/expert-profile.bin" "--expert-cache" "auto"
      "--prefill" "512" "--spec" "4" "--spec-min-p" "0.5"
      "--mtp" "mtp/rt" "--max-context" "32768" "--kv" "int8"
      "--kv-resident" "32768" "--vram-reserve-mib" "1024"
      # "--pool-workers" "N"   # one per physical core minus one; measure for your CPU
    ];
    cwd = ".";
    tokenizer = "packs/iq3xxs/tokenizer";
    model_name = "qwen3.8-flash-next-iq3_xxs";
    log = "strata.log";
    inherit host port;
    env = { STRATA_HIP_PROMPT_F16 = "1"; };
  });
in
{
  users.users.strata = {
    isSystemUser = true;
    group = "strata";
    extraGroups = [ "video" "render" ];
    home = stateDir;
  };
  users.groups.strata = { };

  systemd.tmpfiles.rules = [
    "d ${stateDir}         0750 strata strata -"
    "d ${modelDir}         0750 strata strata -"
    "d ${stateDir}/packs   0750 strata strata -"
    "d ${stateDir}/mtp     0750 strata strata -"
    "d ${stateDir}/data    0750 strata strata -"
  ];

  # For running the packing tools by hand
  environment.systemPackages = [ strata strataPython ];

  systemd.services.strata = {
    description = "Strata inference server (HIP, gfx1030)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    environment = hipEnv // {
      STRATA_HIP_PROMPT_F16 = "1";
      PYTHONPATH = "${inputs.strata-src}";
      STRATA_GGUF_PY = "${inputs.llama-src}/gguf-py";
    };

    serviceConfig = {
      User = "strata";
      Group = "strata";
      WorkingDirectory = stateDir;
      ExecStart = "${strataPython}/bin/python -m serve.server --engine strata --config ${serverConfig} --port ${toString port}";
      LimitMEMLOCK = "infinity";
      Restart = "on-failure";
      # Use MemoryMax if you want a limit; never MemoryHigh (it counts the page cache --mmap-experts reads from)
    };
  };
}
