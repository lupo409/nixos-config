{ config, lib, pkgs, vars, ... }:
{
  users.groups.media = { };

  users.users.${vars.username}.extraGroups = lib.mkAfter [ "media" ];

  services.immich = {
    enable = true;
    mediaLocation = "/data/Pictures";
    group = "media";
    accelerationDevices = null;
    database = {
      enableVectors = false;
    };
  };

  services.immich.machine-learning.environment.MPLCONFIGDIR = "/var/cache/immich/matplotlib";

  services.postgresql = {
    package = pkgs.postgresql_16;
    initdbArgs = [ "--data-checksums" ];
    dataDir = "/var/lib/postgresql/16";
  };

  services.jellyfin = {
    enable = true;
    group = "media";
    hardwareAcceleration = {
      enable = true;
      type = "nvenc";
      device = "/dev/nvidia0";
    };
  };

  systemd.services.jellyfin.serviceConfig.DeviceAllow = lib.mkAfter [
    "/dev/nvidiactl rw"
    "/dev/nvidia-uvm rw"
    "/dev/nvidia-uvm-tools rw"
    "/dev/dri/renderD128 rw"
  ];

  systemd.services.jellyfin.environment = {
    JELLYFIN_PublishedServerUrl = "https://server.tailb7af7.ts.net/jellyfin/";
    JELLYFIN_BASEURL = "/jellyfin";
  };

  services.kavita = {
    enable = true;
    dataDir = "/data/kavita";
    tokenKeyFile = "/data/kavita/config/token.key";
    settings.BaseUrl = "/kavita";
  };

  users.users.immich.extraGroups = [ "media" "video" "render" ];
  users.users.jellyfin.extraGroups = [ "media" "video" "render" ];
  users.users.kavita.extraGroups = [ "media" ];


  systemd.tmpfiles.settings.immich."${config.services.immich.mediaLocation}".e = lib.mkForce {
    user = config.services.immich.user;
    group = config.services.immich.group;
    mode = "0770";
  };

  systemd.tmpfiles.settings."10-media" = {
    "/data/Pictures/encoded-video".d = {
      user = config.services.immich.user;
      group = config.services.immich.group;
      mode = "0770";
    };
    "/data/Pictures/library".d = {
      user = config.services.immich.user;
      group = config.services.immich.group;
      mode = "0770";
    };
    "/data/Pictures/upload".d = {
      user = config.services.immich.user;
      group = config.services.immich.group;
      mode = "0770";
    };
    "/data/Pictures/profile".d = {
      user = config.services.immich.user;
      group = config.services.immich.group;
      mode = "0770";
    };
    "/data/Pictures/thumbs".d = {
      user = config.services.immich.user;
      group = config.services.immich.group;
      mode = "0770";
    };
    "/data/Pictures/backups".d = {
      user = config.services.immich.user;
      group = config.services.immich.group;
      mode = "0770";
    };
    "/data/kavita".d = {
      user = "kavita";
      group = "kavita";
      mode = "0750";
    };
    "/data/kavita/config".d = {
      user = "kavita";
      group = "kavita";
      mode = "0750";
    };
  };

  systemd.tmpfiles.settings."10-immich-ml" = {
    "/var/cache/immich/matplotlib".d = {
      user = config.services.immich.user;
      group = config.services.immich.group;
      mode = "0700";
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;

    virtualHosts."server" = {
      serverName = "localhost";
      listen = [
        {
          addr = "0.0.0.0";
          port = 8100;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
          proxy_request_buffering off;
        '';
      };

      locations."/jellyfin/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };

      locations."/kavita/" = {
        proxyPass = "http://127.0.0.1:5000";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8100 ];
}
