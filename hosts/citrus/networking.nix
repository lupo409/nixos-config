{ config, lib, ... }:
{
  sops.secrets."network/ap0_psk" = { };
  sops.templates.networkmanager_env = {
    path = "/run/secrets/network-manager.env";
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      AP0_PSK=${config.sops.placeholder."network/ap0_psk"}
    '';
  };

  hardware.wirelessRegulatoryDatabase = true;

  networking = {
    usePredictableInterfaceNames = false;

    firewall = {
      trustedInterfaces = [ "wlan0" ];
      extraCommands = ''
        iptables -I INPUT -i eth0 -p icmp --icmp-type echo-request -j DROP
      '';
      extraStopCommands = ''
        iptables -D INPUT -i eth0 -p icmp --icmp-type echo-request -j DROP || true
      '';
      interfaces.wlan0 = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 67 68 ];
      };
    };

    networkmanager = {
      enable = true;
      wifi = {
        backend = "wpa_supplicant";
        scanRandMacAddress = false;
        macAddress = "permanent";
      };
      ensureProfiles = {
        environmentFiles = [ config.sops.templates.networkmanager_env.path ];
        profiles = {
          eth0 = {
            connection = {
              id = "eth0";
              type = "ethernet";
              interface-name = "eth0";
              autoconnect = true;
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              method = "auto";
            };
          };
          ap0 = {
            connection = {
              id = "ap0";
              type = "802-11-wireless";
              interface-name = "wlan0";
              autoconnect = true;
            };
            wifi = {
              mode = "ap";
              ssid = "TPLink-8732";
              band = "a";
              channel = 5;
              powersave = 2;
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$AP0_PSK";
              proto = "rsn";
              pairwise = "ccmp";
              group = "ccmp";
            };
            ipv4 = {
              method = "shared";
            };
            ipv6 = {
              method = "ignore";
            };
          };
        };
      };
    };

  };

  systemd.services."NetworkManager-wait-online".enable = false;
}
