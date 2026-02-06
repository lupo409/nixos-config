{ config, lib, pkgs, vars, ... }:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;
  dmsWeatherCoordinates = "__DMS_WEATHER_COORDINATES__";
  chromiumExec = lib.getExe pkgs.chromium;
  firefoxToolbarState = builtins.toJSON {
    placements = {
      "nav-bar" = [
        "back-button"
        "forward-button"
        "stop-reload-button"
        "urlbar-container"
        "downloads-button"
        "ublock0@raymondhill.net"
        "unified-extensions-button"
      ];
      "toolbar-menubar" = [ "menubar-items" ];
      "TabsToolbar" = [ "tabbrowser-tabs" "alltabs-button" ];
      "PersonalToolbar" = [ "personal-bookmarks" ];
      "unified-extensions-area" = [ ];
    };
    seen = [
      "unified-extensions-button"
      "ublock0@raymondhill.net"
      "downloads-button"
    ];
    dirtyAreaCache = [ "nav-bar" "TabsToolbar" "PersonalToolbar" "toolbar-menubar" ];
    currentVersion = 20;
    newElementCount = 0;
  };
in
{
  programs = {
    eza.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    bottom.enable = true;
    fastfetch.enable = true;

    npm.enable = true;
    uv.enable = true;
    yt-dlp = {
      enable = true;
      settings = {
        embed-metadata = true;
        embed-subs = true;
      };
    };

    chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        {
          id = "ddkjiahejlhfcafbddmgiahcphecmpfh";
        }
      ];
    };

    firefox = {
      enable = true;
      languagePacks = [ "ja" ];
      policies = {
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        DisableAppUpdate = true;
      };
      profiles.default = {
        settings = {
          "extensions.autoDisableScopes" = 0;
          "intl.accept_languages" = "ja-JP,ja,en-US,en";
          "intl.locale.requested" = "ja-JP";
          "browser.startup.page" = 3;
          "browser.sessionstore.resume_from_crash" = true;
          "browser.eme.ui.enabled" = true;
          "media.eme.enabled" = true;
          "media.gmp-widevinecdm.enabled" = true;
          "media.gmp-widevinecdm.visible" = true;
          "media.gmp-manager.updateEnabled" = true;
          "browser.discovery.enabled" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.newtabpage.activity-stream.section.highlights" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.section.topstories" = false;
          "privacy.trackingprotection.enabled" = false;
          "privacy.trackingprotection.pbmode.enabled" = false;
          "privacy.trackingprotection.fingerprinting.enabled" = false;
          "privacy.trackingprotection.cryptomining.enabled" = false;
          "privacy.trackingprotection.socialtracking.enabled" = false;
          "privacy.globalprivacycontrol.enabled" = false;
          "signon.rememberSignons" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "browser.uiCustomization.state" = firefoxToolbarState;

          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.firstRunTelemetry.enabled" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.sessionPing.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.prompted" = false;
          "toolkit.telemetry.autoOpts" = false;
          "toolkit.telemetry.server" = "";
          "datareporting.healthreport.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.policy.fourDayNotificationShown" = false;
          "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
          "browser.ping-centre.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.contentblocking.category" = "custom";
          "privacy.trackingprotection.smartblock.enabled" = false;
          "privacy.socialtracking.block_cookies.enabled" = false;
          "places.history.enabled" = false;
          "browser.urlbar.suggest.history" = false;
          "browser.urlbar.suggest.bookmark" = false;
          "browser.urlbar.suggest.remotetab" = false;
          "browser.urlbar.shortcuts.history" = false;
          "browser.urlbar.shortcuts.bookmarks" = false;
          "browser.urlbar.shortcuts.tabs" = false;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.topsites" = false;
          "network.trr.mode" = 0;
          "network.trr.uri" = "";
          "network.dns.disablePrefetchFromHTTPS" = true;
          "network.trr.confirmationNS" = "";
          "browser.safebrowsing.downloads.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "browser.safebrowsing.phishing.enabled" = false;
          "browser.safebrowsing.blockedURIs.enabled" = false;
          "geo.enabled" = false;
          "geo.provider.useGpsd" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "app.normandy.enabled" = false;
          "app.normandy.runIntervalSeconds" = 100000000;
          "messaging-system.rsexperimentWAA" = false;
          "messaging-system.rwaaOrders" = false;
          "browser.ml.chat.enabled" = false;
          "browser.ml.chat.sidebar" = false;
          "browser.ml.chat.menu" = false;
          "browser.ml.chat.page" = false;
          "browser.ml.chat.page.footerBadge" = false;
          "browser.ml.chat.page.menuBadge" = false;
          "browser.ml.chat.shortcuts" = false;
          "browser.ml.chat.shortcuts.custom" = false;
          "sidebar.notification.badge.aichat" = false;
          "sidebar.main.tools" = "";
          "browser.contextual-password-manager.enabled" = false;
          "services.sync.engine.tabs" = false;
          "services.sync.engine.history" = false;
          "services.sync.engine.passwords" = false;
          "services.sync.engine.bookmarks" = false;
          "services.sync.engine.addresses" = false;
          "services.sync.engine.creditcards" = false;
          "sidebar.visibility" = "expand-on-hover";
          "sidebar.expandOnHover" = true;
          "browser.download.useDownloadDir" = true;
          "browser.download.dir" = "\${env:HOME}/Downloads";
        };
        extensions.packages = [
          addons.bonjourr-startpage
          addons.decentraleyes
          addons.bitwarden
          addons.tampermonkey
          addons.darkreader
          addons.ublock-origin
        ];
        extensions.settings = {
          "ublock0@raymondhill.net" = {
            force = true;
            settings = {
              toAdd = {
                filterLists = [
                  "adguard-spyware-url"
                  "fanboy-cookiemonster"
                  "easylist-annoyances"
                  "ublock-annoyances"
                  "https://github.com/Yuki2718/adblock2/raw/refs/heads/main/japanese/jpf-plus.txt"
                ];
              };
            };
          };
        };
        extensions.force = true;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      dotDir = config.home.homeDirectory;

      history = {
        size = 100000;
        save = 100000;
        share = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
      };

      completionInit = ''
        autoload -Uz compinit
        compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
      '';

      shellAliases = {
        ls = "eza";
        cat = "bat";
        ll = "eza -la --icons";
        lt = "eza --tree --level=2";
        grep = "rg";
        fgrep = "rg";
        egrep = "rg";
        nix-shell = "nix-shell --command zsh";
        ".." = "cd ..";
        "..." = "cd ../..";
        la = "eza -la";
        vim = "nvim";
        vi = "nvim";
        pbcopy = "wl-copy";
        pbpaste = "wl-paste";
      };

      initContent = lib.mkOrder 1000 ''
        eval "$(starship init zsh)"
        eval "$(zoxide init zsh)"

        export EDITOR=nano

        setopt HIST_IGNORE_SPACE
        setopt HIST_IGNORE_ALL_DUPS
        setopt AUTO_CD
        setopt CORRECT
        setopt NO_BEEP
      '';
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = lib.concatStrings [
          "[░▒▓](#a3aed2)"
          "[  ](bg:#a3aed2 fg:#090c0c)"
          "[](bg:#769ff0 fg:#a3aed2)"
          "$directory"
          "[](fg:#769ff0 bg:#394260)"
          "$git_branch"
          "$git_status"
          "[](fg:#394260 bg:#212736)"
          "$nodejs"
          "$rust"
          "$golang"
          "$php"
          "[](fg:#212736 bg:#1d2230)"
          "$time"
          "[ ](fg:#1d2230)"
          "\n$character"
        ];
        add_newline = false;
        line_break.disabled = true;

        directory = {
          style = "fg:#e3e5e5 bg:#769ff0";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
          };
        };

        git_branch = {
          symbol = "";
          style = "bg:#394260";
          format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
        };

        git_status = {
          style = "bg:#394260";
          format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        golang = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        php = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:#1d2230";
          format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
        };

        status = {
          disabled = false;
          style = "fg:red bold";
          symbol = "✖";
        };
      };
    };

    git = {
      enable = true;
      settings = {
        user.name = vars.gitUsername;
        user.email = vars.gitEmail;
        init.defaultBranch = "main";
        pull.rebase = false;
      };
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
      enableGitIntegration = true;
    };
  };

  xdg.desktopEntries = {
    scyrox = {
      name = "Scyrox";
      comment = "Scyrox web app";
      exec = "${chromiumExec} --app=https://www.scyrox.net/ --class=Scyrox";
      icon = "chromium";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };
    xsyd-connect = {
      name = "XSYD Connect";
      comment = "XSYD Connect web app";
      exec = "${chromiumExec} --app=https://v2.xsyd.top/connect --class=XSYDConnect";
      icon = "chromium";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };
  };

  xdg.configFile."ghostty/config" = {
    text = ''
      font-family = "HackGen Console NF"
      font-size = 12
      theme = dankcolors
      scrollback-limit = 10000
      cursor-style = "block"
      cursor-blink = true
      window-padding-x = 8
      window-padding-y = 8
      confirm-close-surface = false
      app-notifications = "no-clipboard-copy,no-config-reload"
    '';
    force = true;
  };

  xdg.configFile."DankMaterialShell/settings.json" = {
    source = ./dms/settings.json;
    force = true;
  };

  home.file.".config/niri/config.kdl".source = ./niri-config.kdl;
  home.file.".config/niri/dms/binds.kdl".source = ./dms/binds.kdl;
  home.file.".config/niri/dms/layout.kdl".source = ./dms/layout.kdl;
  home.file.".config/niri/dms/outputs.kdl".source = ./dms/outputs.kdl;
  home.file.".config/niri/dms/colors.kdl".source = ./dms/colors.kdl;
  home.file.".config/niri/dms/alttab.kdl".source = ./dms/alttab.kdl;
  home.file.".config/niri/dms/cursor.kdl".source = ./dms/cursor.kdl;
  home.file.".config/niri/dms/wpblur.kdl".source = ./dms/wpblur.kdl;

  xdg.configFile."DankMaterialShell/firefox.css" = {
    source = ./dms/firefox.css;
    force = true;
  };

  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    [General]
    Theme=FluentDark-solid
  '';
}
