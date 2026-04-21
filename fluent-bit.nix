###############################################################################
# Fluent-bit
###############################################################################
{ config, lib, pkgs, ... }:
{
  sops.secrets = {
    "elastic_password" = {};
    "es_host" = {};
    "elastic_user" = {};
  };

  # Lua script to parse Tailscale SSH sessions from login _CMDLINE
  environment.etc."fluent-bit/tailscale-parse.lua".text = ''
    function parse_tailscale(tag, timestamp, record)
      local cmdline = record["_CMDLINE"]
      if cmdline then
        -- Match Tailscale CGNAT IP in -h 100.x.x.x
        local ip = string.match(cmdline, "-h%s+(100%.[%d%.]+)")
        if ip then
          record["tailscale_src_ip"] = ip
          record["tailscale_ssh"]    = true
          record["event_type"]       = "tailscale_login"
        end
      end
      return 1, timestamp, record
    end
  '';

  environment.etc."fluent-bit/fail2ban-parse.lua".text = ''
    function parse_fail2ban(tag, timestamp, record)
      local msg = record["message"] or ""
      local jail, action, ip = string.match(msg, "%[([^%]]+)%]%s+(%w+)%s+([%d%.]+)")
      if jail then
        record["jail"] = jail
        record["action"] = action
        record["src_ip"] = ip
      end
      local jail_only = string.match(msg, "%[([^%]]+)%]")
      if jail_only and not jail then
        record["jail"] = jail_only
      end
      return 1, timestamp, record
    end
  '';

  sops.templates."fluent-bit.conf" = {
    content = ''
      [SERVICE]
          flush     1
          log_level info
          daemon    off
          Parsers_File /etc/fluent-bit/parsers.conf

      [INPUT]
          name    systemd
          tag     dailydriver.journal

      [INPUT]
          name tail
          path /var/log/*.log
          tag  nixos.tail

      [INPUT]
          name              systemd
          tag               dailydriver.fail2ban
          systemd_filter    _SYSTEMD_UNIT=fail2ban.service
          db                /var/lib/fluent-bit/fail2ban.db

      [FILTER]
          name   modify
          match  *
          remove SYSLOG_TIMESTAMP

      [FILTER]
          name    lua
          match   *.journal
          script  /etc/fluent-bit/tailscale-parse.lua
          call    parse_tailscale

      [FILTER]
          name   lua
          match  dailydriver.fail2ban
          script /etc/fluent-bit/fail2ban-parse.lua
          call   parse_fail2ban

      [FILTER]
          name     record_modifier
          match    dailydriver.*
          Record   hostname playwashere
          Record   source   dailydriver

      [OUTPUT]
          name               es
          match              *
          host               ${config.sops.placeholder."es_host"}
          port               9200
          http_user          ${config.sops.placeholder."elastic_user"}
          http_passwd        ${config.sops.placeholder."elastic_password"}
          logstash_format    On
          logstash_prefix    dailydriver
          suppress_type_name On
          buffer_size        10MB
    '';
    path = "/run/secrets/fluent-bit.conf";
    mode = "0444";
    owner = "root";
    group = "root";
  };

  services.fluent-bit = {
    enable = true;
    configurationFile = config.sops.templates."fluent-bit.conf".path;
  };

  systemd.services.fluent-bit = {
    serviceConfig = {
      SupplementaryGroups = [ "adm" ];
      StateDirectory      = lib.mkForce "fluent-bit";
      StateDirectoryMode  = "0750";
    };
  };
}
