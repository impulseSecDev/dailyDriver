###############################################################################
# Virtualization 
###############################################################################
{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

 #Build flakes for rasberypi aaarch64 
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
