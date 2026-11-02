{ config, pkgs, lib, inputs, ... }:
let
  rp = pkgs.rocmPackages;

  rocm = pkgs.symlinkJoin {
    name = "rocm-merged";
    paths = with rp; [ clr hipblas rocblas rocm-device-libs rocm-comgr rocm-runtime ];
  };

  hipEnv = {
    ROCM_PATH = "${rocm}";
    HIP_PATH = "${rocm}";
    HIP_DEVICE_LIB_PATH = "${rp.rocm-device-libs}/amdgcn/bitcode";
  };

  strata = pkgs.stdenv.mkDerivation ({
    pname = "strata-gfx1030";
    version = "git-${inputs.strata-src.shortRev or "dirty"}";
    src = inputs.strata-src;

    nativeBuildInputs = with pkgs; [ cmake ninja git python3 ];
    buildInputs = [ rocm ];

    preConfigure = ''
      cp -r ${inputs.llama-src} $TMPDIR/llama
      chmod -R u+w $TMPDIR/llama
    '';

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DSTRATA_ENABLE_HIP=ON"
      "-DSTRATA_ENABLE_CUDA=OFF"
      "-DCMAKE_HIP_ARCHITECTURES=gfx1030"
      "-DCMAKE_HIP_COMPILER=${rocm}/llvm/bin/clang++"
      "-DSTRATA_GGML_DIR=$TMPDIR/llama"
      "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    ];

    ninjaFlags = [ "strata" ];
    installPhase = "install -Dm755 strata $out/bin/strata";
  } // hipEnv);
in
{
  users.users.strata = {
    isSystemUser = true;
    group = "strata";
    extraGroups = [ "video" "render" ];
    home = "/var/lib/strata";
  };
  users.groups.strata = { };

  systemd.tmpfiles.rules = [ "d /var/lib/strata 0750 strata strata -" ];

  environment.systemPackages = [ strata ];   # handy for running the packer/engine by hand

  systemd.services.strata = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = hipEnv // {
      STRATA_HIP_PROMPT_F16 = "1";
    };
    serviceConfig = {
      User = "strata";
      WorkingDirectory = "/var/lib/strata";
      LimitMEMLOCK = "infinity";
      Restart = "on-failure";
      # Placeholder: the real command is the repo's serve/server.py with a strata-hip.json
      # whose "exe" is ${strata}/bin/strata. Fill in once the Python side is sorted.
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };
}
