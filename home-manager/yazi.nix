{ pkgs, ... }:
let
  yaziPluginsSrc = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "230b9c6055a3144f6974fef297ad1a91b46a6aac";
    hash = "sha256-dd2PWWi/HsdLWEUci5lP+Vc2IABtpEleaR/aMFUC3Qw=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    extraPackages = with pkgs; [
      bat
      eza
      glow
      hexyl
    ];
    settings = {
      mgr = {
        sort_by = "mtime";
        sort_dir_first = true;
        sort_reverse = true;
      };
      preview = {
        max_width = 1200;
        max_height = 1200;
      };
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
          }
          {
            id = "git";
            url = "*/";
            run = "git";
          }
        ];
        prepend_previewers = [
          {
            url = "*/";
            run = "piper -- eza -TL=3 --color=always --icons=always --group-directories-first --no-quotes \"$1\"";
          }
          {
            url = "*.md";
            run = "piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark \"$1\"";
          }
        ];
      };
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "l";
          run = "plugin smart-enter";
          desc = "Enter or open";
        }
        {
          on = "F";
          run = "plugin smart-filter";
          desc = "Smart filter";
        }
        {
          on = "f";
          run = "plugin jump-to-char";
          desc = "Jump to char";
        }
        {
          on = "p";
          run = "plugin smart-paste";
          desc = "Smart paste";
        }
        {
          on = "T";
          run = "plugin toggle-pane min-preview";
          desc = "Toggle preview";
        }
        {
          on = "<C-d>";
          run = "plugin diff";
          desc = "Diff selected with hovered";
        }
      ];
    };
    initLua = ''
      require("full-border"):setup {
        type = ui.Border.ROUNDED,
      }

      require("git"):setup {
        order = 1500,
      }

      require("smart-enter"):setup {
        open_multi = true,
      }
    '';
    plugins = {
      "smart-enter" = "${yaziPluginsSrc}/smart-enter.yazi";
      "smart-filter" = "${yaziPluginsSrc}/smart-filter.yazi";
      "jump-to-char" = "${yaziPluginsSrc}/jump-to-char.yazi";
      "smart-paste" = "${yaziPluginsSrc}/smart-paste.yazi";
      "toggle-pane" = "${yaziPluginsSrc}/toggle-pane.yazi";
      "diff" = "${yaziPluginsSrc}/diff.yazi";
      "git" = "${yaziPluginsSrc}/git.yazi";
      "full-border" = "${yaziPluginsSrc}/full-border.yazi";
      "piper" = "${yaziPluginsSrc}/piper.yazi";
    };
  };
}
