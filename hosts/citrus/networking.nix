{ lib, pkgs, ... }:
{
  hardware.wirelessRegulatoryDatabase = true;

  boot.kernelParams = [ "net.ifnames=0" "biosdevname=0" ];

  networking = {
    networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        br0 = {
          connection = {
            id = "br0";
            type = "bridge";
            interface-name = "br0";
            autoconnect = true;
          };
          bridge = {
            stp = false;
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            method = "ignore";
          };
        };

        eth0 = {
          connection = {
            id = "eth0";
            type = "ethernet";
            interface-name = "eth0";
            master = "br0";
            slave-type = "bridge";
            autoconnect = true;
          };
          ethernet = { };
        };

        ap0 = {
          connection = {
            id = "ap0";
            type = "wifi";
            interface-name = "ap0";
            master = "br0";
            slave-type = "bridge";
            autoconnect = true;
          };
          wifi = {
            mode = "ap";
            ssid = "Citrus-AX";
            band = "a";
            channel = 36;
            powersave = 2;
          };
          ipv4 = {
            method = "disabled";
          };
          ipv6 = {
            method = "ignore";
          };
        };
      };
    };

    wireless.enable = lib.mkForce false;
    usePredictableInterfaceNames = false;
  };

  systemd.services.nm-ap0-setup = {
    description = "Create ap0 interface for NetworkManager";
    after = [ "network-pre.target" ];
    wants = [ "network-pre.target" ];
    before = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iw}/bin/iw dev wlan0 interface add ap0 type __ap";
      ExecStop = "${pkgs.iw}/bin/iw dev ap0 del";
    };
  };
}
