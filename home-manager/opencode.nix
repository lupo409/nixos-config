{ lib, pkgs, ... }:
let
  agentBrowserSkill = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/vercel-labs/agent-browser/main/skills/agent-browser/SKILL.md";
    hash = "sha256-hO/7QjcbrEmRI4QwiP5DBNi3xd52VyLjrZLMD3zGhVc=";
  };
  grepaiSkill = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/yoanbernabeu/grepai/main/.claude/skills/grepai/SKILL.md";
    hash = "sha256-2Cpy4/Mkat44+aFRsQWlNhdzHHEw5KFwzOyi9RbsmQg=";
  };
in
{
  home.sessionVariables.AGENT_BROWSER_EXECUTABLE_PATH = lib.getExe pkgs.chromium;

  xdg.configFile."opencode/config.yaml" = {
    text = ''
      theme: system
      mcp:
        serena:
          type: local
          enabled: true
          command:
            - uvx
            - --from
            - git+https://github.com/oraios/serena
            - serena
            - start-mcp-server
            - --context
            - ide
            - --project-from-cwd
        grepai:
          type: local
          enabled: true
          command:
            - grepai
            - mcp-serve
    '';
    force = true;
  };

  xdg.configFile."opencode/skills/grepai/SKILL.md" = {
    source = grepaiSkill;
    force = true;
  };

  xdg.configFile."opencode/skills/agent-browser/SKILL.md" = {
    source = agentBrowserSkill;
    force = true;
  };
}
