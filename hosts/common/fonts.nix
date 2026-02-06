{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    hackgen-font
    hackgen-nf-font
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Noto Sans CJK JP" "Noto Sans CJK" ];
      serif = [ "Noto Serif CJK JP" "Noto Serif CJK" ];
      monospace = [ "HackGen Console NF" "HackGen Console" "HackGen" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
