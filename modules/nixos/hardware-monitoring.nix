{ pkgs, ... }:
{
  # Enable hardware monitoring
  hardware.sensor.iio.enable = true;

  # Enable lm_sensors
  environment.systemPackages = with pkgs; [
    lm_sensors
    powertop
    ddcutil
  ];

  # Load hardware monitoring kernel modules
  boot.kernelModules = [ "coretemp" "nct6775" "k10temp" "i2c-dev" "ddcci-backlight" ];

  # NVIDIA GPU power management settings
  hardware.nvidia.powerManagement.enable = true;

  # Enable thermal management
  services.thermald.enable = true;

  # DDC/CI (Display Data Channel Command Interface) for external monitor brightness control
  # This allows brightnessctl to control external monitors via I2C
  services.udev.extraRules = ''
    # Grant access to I2C devices for DDC/CI control
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';

  # Ensure i2c group exists
  users.groups.i2c = {};
}
