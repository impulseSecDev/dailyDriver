###############################################################################
# networking
###############################################################################
{ config, pkgs, ... }:

{
  sops.secrets = {
    "fail2ban_ignoreip" ={};
    "headscale_hostname" = {};
    "headscale_user" = {};
  };

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = false;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  sops.templates."ssh_config" = {
    content = ''
      Host headscale
        Hostname ${config.sops.placeholder."headscale_hostname"}
        IdentityFile ~/.ssh/ssh_keys/headscale
        user ${config.sops.placeholder."headscale_user"}
        CheckHostIP yes
    '';
    path = "/home/tim/.ssh/config";
    owner = "tim";  # important - ssh requires the file is owned by the user
    mode = "0600";  # ssh is strict about config file permissions
  };

  # networking.firewall.enable = false;

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1d"; # Default ban time for 1 day
    bantime-increment = {
      enable = true;
      formula = "ban.Time * 1.5"; # Simple formula to increase ban time by 50% for each offense
      maxtime = "1w"; # Maximum ban time of 1 week
      overalljails = true;
    };

    jails = {
      # Protects against SSH brute-force attacks.
      sshd = {
        enabled = true;
        settings = {
          journalmatch = "_SYSTEMD_UNIT=sshd.service";
          bantime = "2d"; # A longer ban time for SSH attacks
          findtime = 600; # 10 minutes
          maxretry = 3; # Very few retries to prevent password guessing
        };
      };
      #Catches bots and scanners hitting a web server.
      http-badbots = {
        enabled = true;
        settings = {
          port = "http,https";
          journalmatch = "_SYSTEMD_UNIT=httpd.service"; 
          filter = "http-badbots"; # This is a built-in Fail2ban filter
          maxretry = 2; # Very low tolerance
          bantime = "3h";
        };
      };
    };
  };

  environment.etc = {
    "fail2ban/filter.d/open-webui.conf".text = ''
      [Definition]
      failregex = .*POST /api/v1/auth/login.*401.*
      ignoreregex =
    '';
  };

  # fail2banIgnore IP template
  sops.templates."fail2ban-jail-ignoreip.local" = {
    content = ''
      [DEFAULT]
      ignoreip = ${config.sops.placeholder."fail2ban_ignoreip"}
    '';
    path = "/etc/fail2ban/jail.d/ignoreip.local";  # jail.d/ not jail.local
  };

# Create the log directory and ensure permissions are correct
  systemd.tmpfiles.rules = [
    "d /var/log/open-webui 0755 open-webui open-webui - -"
  ];
}
