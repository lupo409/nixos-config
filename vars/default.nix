{
  user = "takahiro";
  gitUsername = "Lupo409";
  gitEmail = "249657796+lupo409@users.noreply.github.com";

  hosts = {
    Yuzu = {
      system = "x86_64-linux";
      type = "wsl";
    };
    Citrus = {
      system = "x86_64-linux";
      type = "nixos";
    };
    Sudachi = {
      system = "aarch64-darwin";
      type = "darwin";
    };
  };
}
