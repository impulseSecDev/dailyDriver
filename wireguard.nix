###############################################################################
# Wireguard config
###############################################################################
{ config, lib, pkgs, ... }:
{

  sops.secrets = {
    "wg0_private_key" = {};
    "wg0_elk_allowedips" = {};
    "wg0_elk_endpoint" = {};
    "wg0_wazuh_allowedips" = {};
    "wg0_wazuh_endpoint" = {};
    "wg1_private_key" = {};
    "wg1_vps_endpoint" = {};
    "wg1_vps_allowedips" = {};
  };
sops.templates."wg0.conf" = {
  content = ''
    [Interface]
    PrivateKey = ${config.sops.placeholder."wg0_private_key"}
    Address = 10.10.10.4/32

    [Peer]
    # Elk
    PublicKey = wW4FLWFhZGOyzUnnf3cFTNlcmcXgc7E7S6LobwFF3Tc=
    AllowedIPs = ${config.sops.placeholder."wg0_elk_allowedips"}
    Endpoint = ${config.sops.placeholder."wg0_elk_endpoint"}
    PersistentKeepalive = 25

    [Peer]
    # Wazuh
    PublicKey = na1tRGq7v+sZyAwPMJrYzI2MFq7z4Y8EKhWaMaB5ZB4=
    AllowedIPs = ${config.sops.placeholder."wg0_wazuh_allowedips"}
    Endpoint = ${config.sops.placeholder."wg0_wazuh_endpoint"}
    PersistentKeepalive = 25
  '';
  path = "/run/secrets/wg0.conf";
  mode = "0400";
};

sops.templates."wg1.conf" = {
  content = ''
    [Interface]
    PrivateKey = ${config.sops.placeholder."wg1_private_key"}
    Address = 10.10.90.2/24

    [Peer]
    # VPS
    PublicKey = fXpSh3d1icVlTOPV/AS5YLTfg/4rkaCPWJMls0oPK3E=
    AllowedIPs = ${config.sops.placeholder."wg1_vps_allowedips"}
    Endpoint = ${config.sops.placeholder."wg1_vps_endpoint"}
    PersistentKeepalive = 25
  '';
  path = "/run/secrets/wg1.conf";
  mode = "0400";
};

networking.wg-quick.interfaces = {
  wg0.configFile = config.sops.templates."wg0.conf".path;
  wg1.configFile = config.sops.templates."wg1.conf".path;
};

networking.firewall.checkReversePath = "loose";}
