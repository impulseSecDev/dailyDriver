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
    };
    certs = {
      "mesh.loranjennings.com" = {
        domain = "*.mesh.loranjennings.com";
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare_api_token".path;
        };
        group = "nginx";
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true; # Sets Host and X-Forwarded-* on every proxied location

    virtualHosts = {
      # Default Fallback for HTTP (Port 80)
      "default-http-fallback" = {
        default = true; # Catches all traffic not matched by other virtual hosts
        listen = [ { addr = "100.64.0.5"; port = 80; } ];
        extraConfig = ''
          server_name _;
          error_page 400 401 402 403 404 405 429 497 500 =444 /;
          return 444;
        '';
      };

      # Default Fallback for HTTPS (Port 443)
      "default-https-fallback" = {
        default = true; # Catches all traffic not matched by other virtual hosts
        listen = [ { addr = "100.64.0.5"; port = 443; ssl = true; } ];
        extraConfig = ''
          server_name _;
          ssl_reject_handshake on; # Reject non-SSL attempts
          error_page 400 401 402 403 404 405 429 497 500 =444 /;
          return 444;
        '';
      };

      "gpt.mesh.loranjennings.com" = {
        useACMEHost = "mesh.loranjennings.com";
        onlySSL = true; 
        http2 = false;  # Prevents HTTP/2 + Tailscale MTU stalls on Socket.IO / SSE streams
        listen = [ { addr = "100.64.0.5"; port = 443; ssl = true; } ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
            proxy_cache off;
            proxy_request_buffering off;
            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
            proxy_connect_timeout 600s;
            client_max_body_size 50M;
          '';
        };
      };

      "llama.mesh.loranjennings.com" = {
        useACMEHost = "mesh.loranjennings.com";
        onlySSL = true;
        http2 = false;
        listen = [ { addr = "100.64.0.5"; port = 443; ssl = true; } ];
        locations."/" = {
          proxyPass = "http://127.1.0.1:8080";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
          '';
        };
      };
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 443 ];
}
