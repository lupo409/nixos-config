{ vars, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user.name = vars.gitUsername;
      user.email = vars.gitEmail;
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
    };
    enableGitIntegration = true;
  };
}
