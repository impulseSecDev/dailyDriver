###############################################################################
# services
###############################################################################
{config, lib, pkgs, ... }:

{
  services.udisks2.enable = true;
  
  services.teamviewer.enable = true;

  services.lact.enable = true;

  services.flatpak.enable = true;

  services.printing = {
    enable = true;
    cups-pdf = {
      enable = true;
      instances.pdf.settings = {
        Out = "/home/tim/Work/prints";
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.relayHosts = ["100.64.0.1"];
  };
}
