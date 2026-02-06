{ pkgs, ... }:
let
  fluentFcitx5ThemeName = "FluentDark-solid";
  fluentFcitx5Theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "fluent-fcitx5-theme";
    version = "2025-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "Reverier-Xu";
      repo = "Fluent-fcitx5";
      rev = "399699ac7d366ed6c1952646ed71647e3c8f99b5";
      hash = "sha256-WcYCxWKHe4XX4juq4rxgLXaYAtKtz/SmcPKhA9/TD6E=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fcitx5/themes
      cp -r Fluent* $out/share/fcitx5/themes/
      runHook postInstall
    '';
  };
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    qt6Packages.fcitx5-qt
    libsForQt5.fcitx5-qt
    qt6Packages.fcitx5-configtool
    fluentFcitx5Theme
  ];

  environment.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "fcitx";
    INPUT_METHOD = "fcitx";
    FCITX5_THEME = fluentFcitx5ThemeName;
  };

  # Create fcitx5 configuration with theme
  environment.etc."xdg/fcitx5/conf/classicui.conf".text = ''
    [General]
    Theme=${fluentFcitx5ThemeName}
    UseDarkTheme=True
    UseAccentColor=True
  '';
}
