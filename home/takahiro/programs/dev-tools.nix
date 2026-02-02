{ pkgs, inputs, ... }:
{
  programs = {
    npm.enable = true;
    uv.enable = true;
    yt-dlp = {
      enable = true;
      settings = {
        embed-metadata = true;
        embed-subs = true;
      };
    };
  };

  home.packages = with pkgs; [
    graalvmPackages.graalvm-ce
    deno
    ffmpeg
    opencode
    (python3.withPackages (ps: with ps; [
      certifi
      brotli
      curl-cffi
      mutagen
      xattr
      pycryptodomex
    ]))
  ] ++ [ inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
