{ lib, pkgs, ... }:
{
  hardware.wirelessRegulatoryDatabase = true;

  networking = {
    networkmanager = {
      enable = true;
      unmanaged = [ "interface-name:ap0" "interface-name:br0" ];
    };

    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
    interfaces.ap0.useDHCP = false;
    interfaces.br0.useDHCP = true;

    usePredictableInterfaceNames = false;

    wireless.enable = lib.mkForce false;

    bridges.br0.interfaces = [ "eth0" "ap0" ];
  };

  services.hostapd = {
    enable = true;
    radios.ap0 = {
      band = "5g";
      channel = 36;
      countryCode = "JP";

      wifi6 = {
        enable = true;
        operatingChannelWidth = "80";
      };

      wifi5.operatingChannelWidth = "80";

      settings = {
        uapsd_advertisement_enabled = false;
      };

      networks.ap0 = {
        ssid = "TPLink-8732";
        authentication.mode = "none";

        settings = {
          bridge = "br0";
          beacon_int = 100;
          dtim_period = 1;
          wmm_enabled = true;
        };
      };
    };
  };

  systemd.services.wlan0-ap0 = {
    description = "Create ap0 interface from wlan0";
    after = [ "network-pre.target" ];
    wants = [ "network-pre.target" ];
    before = [ "network-setup.service" "hostapd.service" "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iw}/bin/iw dev wlan0 interface add ap0 type __ap";
      ExecStop = "${pkgs.iw}/bin/iw dev ap0 del";
    };
  };
}
