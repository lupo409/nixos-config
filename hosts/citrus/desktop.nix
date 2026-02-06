{ inputs, pkgs, ... }:
{
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    systemd.target = "graphical-session.target";
    dgop.package = pkgs.dgop;
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
    quickshell.package = inputs.dankmaterialshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    plugins = {
      nixMonitor.enable = true;
      tailscale.enable = true;
    };
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
  };

  programs.dsearch = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
  };
}
