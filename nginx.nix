{ config, pkgs, ... }:

{
  sops.secrets = {
    # Ensure the acme service can actually read the decrypted file
    "cloudflare_api_token" = {
      owner = config.users.users.acme.name;
    };
    "acme_email" = {
      owner = config.users.users.acme.name;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "placeholder@mesh.com"; 
      # environmentFile is no longer strictly needed if using credentialFiles
    };
    certs = {
      "mesh.loranjennings.com" = {
        domain = "*.mesh.loranjennings.com";
        dnsProvider = "cloudflare";
        
        # FIX: Use an attribute set with the _FILE suffix
        credentialFiles = {
          "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare_api_token".path;
        };
        
        group = "nginx";
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."playwashere.mesh.loranjennings.com" = {
      useACMEHost = "mesh.loranjennings.com";
      forceSSL = true;
      # Tailscale interface binding looks good
      listen = [ { addr = "100.64.0.1"; port = 443; ssl = true; } ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
        '';
      };
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 443 ];
}
