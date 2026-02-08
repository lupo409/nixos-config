{ config, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    forceFullCompositionPipeline = true;
  };

  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = [ "nvidia" ];

  # Disable VRR to prevent refresh rate switching issues
  environment.variables = {
    __GL_VRR_ALLOWED = "0";
  };
}
