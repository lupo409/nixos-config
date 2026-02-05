{ config, lib, pkgs, vars, ... }:
{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;
  home.stateVersion = "26.05";

  xdg.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };


  home.activation.dmsWeatherCoordinates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    coords_file="/run/secrets/dms/weather_coordinates"
    settings_file="${config.xdg.configHome}/DankMaterialShell/settings.json"

    if [ -f "$coords_file" ] && [ -f "$settings_file" ]; then
      coords="$(tr -d '\n' < "$coords_file")"
      if [ -n "$coords" ]; then
        tmp_file="$(mktemp)"
        ${lib.getExe pkgs.jq} --arg coords "$coords" '.weatherCoordinates=$coords' "$settings_file" > "$tmp_file" && mv "$tmp_file" "$settings_file"
      fi
    fi
  '';

  programs.home-manager.enable = true;
}
