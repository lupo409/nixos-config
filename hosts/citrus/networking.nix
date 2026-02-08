{ config, lib, pkgs, ... }:
{
  sops.secrets."network/ap0_psk" = { };

  hardware.wirelessRegulatoryDatabase = true;

  networking = {
    usePredictableInterfaceNames = false;
    wireless.enable = lib.mkForce false;

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
      unmanaged = [ "wlan0" ];
      wifi.scanRandMacAddress = false;
      ensureProfiles = {
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
        };
      };
    };

    interfaces.wlan0 = {
      ipv4.addresses = [{
        address = "10.42.0.1";
        prefixLength = 24;
      }];
    };
  };

  services.hostapd = {
    enable = true;
    radios.wlan0 = {
      band = "5g";
      channel = 36;
      countryCode = "JP";
      wifi4.enable = true;
      wifi5.enable = true;
      networks.wlan0 = {
        ssid = "TPLink-8732";
        authentication = {
          mode = "wpa2-sha256";
          wpaPasswordFile = config.sops.secrets."network/ap0_psk".path;
        };
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "wlan0";
      bind-interfaces = true;
      dhcp-range = "10.42.0.10,10.42.0.254,3600";
      dhcp-option = [ "3,10.42.0.1" "6,10.42.0.1" ];
      server = [ "8.8.8.8" ];
      listen-address = "10.42.0.1";
    };
  };

  systemd.services."NetworkManager-wait-online".enable = false;
}
