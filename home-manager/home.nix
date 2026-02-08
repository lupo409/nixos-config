{ config, lib, pkgs, vars, nixosConfig, ... }:
{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;
  home.stateVersion = "26.05";

  xdg.enable = true;

  home.sessionVariables = {
    QS_ICON_THEME = "Papirus-Dark";
  };

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
    platformTheme.name = "qt6ct";
    style.name = "kvantum";
  };

  xdg.configFile."qt6ct/qt6ct.conf" = {
    force = true;
    text = ''
      [Appearance]
      style=kvantum
      icon_theme=Papirus-Dark
    '';
  };

  xdg.configFile."Kvantum/kvantum.kvconfig" = {
    force = true;
    text = ''
      [General]
      theme=FluentDark
    '';
  };


  home.activation.dmsWeatherCoordinates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    coords_file="${nixosConfig.sops.secrets."dms/weather_coordinates".path}"
    settings_file="${config.xdg.configHome}/DankMaterialShell/settings.json"

    if [ -r "$coords_file" ] && [ -f "$settings_file" ]; then
      coords="$(tr -d '\n' < "$coords_file")"
      if [ -n "$coords" ]; then
        tmp_file="$(mktemp)"
        ${lib.getExe pkgs.jq} --arg coords "$coords" '.weatherCoordinates=$coords' "$settings_file" > "$tmp_file" && mv "$tmp_file" "$settings_file"
      fi
    fi
  '';

  home.activation.nixGithubToken = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    token="$(${lib.getExe pkgs.gh} auth token --hostname github.com 2>/dev/null || true)"
    config_dir="${config.xdg.configHome}/nix"
    config_file="$config_dir/nix.conf"

    if [ -n "$token" ]; then
      mkdir -p "$config_dir"
      printf "access-tokens = github.com=%s\n" "$token" > "$config_file"
    else
      rm -f "$config_file"
    fi
  '';

  programs.home-manager.enable = true;
}
