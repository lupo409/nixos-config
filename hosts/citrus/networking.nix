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
      trustedInterfaces = [ "ap0" ];
      allowedUDPPorts = [ 53 67 68 ];
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
              id = "eth0_conf";
              type = "ethernet";
              interface-name = "eth0";
            };
            ethernet = { };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "default";
              method = "auto";
            };
            proxy = { };
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
              channel = 36;
              powersave = 2;
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$AP0_PSK";
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
