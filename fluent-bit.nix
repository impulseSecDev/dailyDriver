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

  sops.templates."fluent-bit.conf" = {
    content = ''
      [SERVICE]
          flush     1
          log_level info
          daemon    off

      [INPUT]
          name    systemd
          tag     dailydriver.journal

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
    serviceConfig.SupplementaryGroups = [ "adm" ];
  };

  # Prevents flunetbit from resending logs on system restart or crash
  systemd.tmpfiles.rules = [
    "d /var/lib/fluent-bit 0750 fluent-bit fluent-bit -"
  ];
}
