{config, pkgs, lib, ...}:
{
  services.monado = {
    enable = true;
    defaultRuntime = true;
    environment = {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
    };
  };
}
