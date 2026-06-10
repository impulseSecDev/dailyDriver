{config, pkgs, lib, ...}:
{
  services.monado = {
    enable = true;
    defaultRuntime = true;
    package = pkgs.monado.override { stdenv = pkgs.clangStdenv; };
  };

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };
}
