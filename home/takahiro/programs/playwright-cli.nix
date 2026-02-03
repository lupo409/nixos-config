{ pkgs, lib, ... }:
{
  xdg.configFile."playwright-cli/config.json".text = ''
    {
      "browser": "chromium",
      "executablePath": "${lib.getExe pkgs.chromium}"
    }
  '';
}
