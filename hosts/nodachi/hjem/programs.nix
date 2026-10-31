{
  osConfig,
  pkgs,
  inputs,
  ...
}:
let
  home = osConfig.constants.home;
in
{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historySize = 1000;
      historyFileSize = 1000;
      historyIgnore = [
        "clear"
        "exit"
      ];
    };

    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    firefox = {
      enable = true;
      package = pkgs.firefox;
      policies = {
        AppAutoUpdate = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        BackgroundAppUpdate = false;
        # CaptivePortal = true;
        DisableAppUpdate = true;
        DisableBuiltinPDFViewer = true;
        DisableFeedbackCommands = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = false;
        DisablePasswordReveal = true;
        DisablePocket = true;
        DisableProfileImport = true;
        DisableSafeMode = true;
        DisableSetDesktopBackground = true;
        DisableSystemAddonUpdate = true;
        DisableTelemetry = true;
        DNSOverHTTPS = {
          Enabled = true;
          ProviderURL = "https://dns.quad9.net/dns-query";
          Locked = true;
        };
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };
        EncryptedMediaExtensions = {
          Enabled = true;
          Locked = true;
        };
        ExtensionUpdate = true;
        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
          Locked = true;
        };
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
        HardwareAcceleration = true;
        Homepage = {
          Locked = true;
          StartPage = "none";
        };
        HttpsOnlyMode = "force_enabled";
        NetworkPrediction = false;
        NewTabPage = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        PasswordManagerEnabled = false;
        PDFjs = {
          Enabled = false;
          EnablePermissions = false;
        };
        PopupBlocking = {
          Default = true;
        };
        Permissions = {
          Camera = {
            BlockNewRequests = false;
            Locked = true;
          };
          Microphone = {
            BlockNewRequests = false;
            Locked = true;
          };
          Location = {
            BlockNewRequests = true;
            Locked = true;
          };
          Notifications = {
            BlockNewRequests = true;
            Locked = true;
          };
          Autoplay = {
            Default = "block-audio-video";
            Locked = true;
          };
        };
        PictureInPicture = {
          Enabled = false;
          Locked = true;
        };
        PostQuantumKeyAgreementEnabled = true;
        PrintingEnabled = true;
        SearchBar = "unified";
        SearchSuggestEnabled = false;
        ShowHomeButton = false;
        StartDownloadsInTempDirectory = true;
        SanitizeOnShutdown = {
          Cache = true;
          Cookies = true;
          History = true;
          Sessions = true;
          SiteSettings = true;
          Locked = true;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          UrlbarInterventions = false;
          SkipOnboarding = true;
          MoreFromMozilla = false;
          FirefoxLabs = false;
          Locked = true;
        };
        UseSystemPrintDialog = true;
        Preferences = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          "widget.use-xdg-desktop-portal.location" = 0;
          "widget.use-xdg-desktop-portal.mime-handler" = 1;
          "widget.use-xdg-desktop-portal.open-uri" = 1;
          "widget.use-xdg-desktop-portal.settings" = 1;
        };
      };
      profiles.default = {
        id = 0;
        name = "default";
        path = "default";
        isDefault = true;
      };
      search = {
        profileName = "default";
        engines = {
          "Brave" = {
            urls = [
              {
                template = "https://search.brave.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                  {
                    name = "safesearch";
                    value = "off";
                  }
                ];
              }
            ];
            icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/brave.svg";
            definedAliases = [ "@br" ];
          };
          "bing".metaData.hidden = true;
          "google".metaData.hidden = true;
          "Bookmarks".metaData.hidden = true;
          "LibRedirect".metaData.hidden = true;
        };
        default = "Brave";
        privateDefault = "Brave";
        order = [
          "Brave"
          "ddg"
        ];
      };
      extensions = {
        force = true;
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          bitwarden
          aria2-integration
          proton-vpn
          auto-tab-discard
          cookie-autodelete
          darkreader
          libredirect
          linkhints
          skip-redirect
          ublock-origin
          stylus
          violentmonkey
        ];
      };
    };

    gitui.enable = true;

    fzf.enable = true;
    zoxide.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = true;
      matchBlocks = {
        github = {
          hostname = "github.com";
          identityFile = [ "${home}/.ssh/ssh_id_ed25519_key" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "gitlab.com" = {
          hostname = "gitlab.com";
          identityFile = [ "${home}/.ssh/id_isc_gitlab" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "codeberg.org" = {
          hostname = "codeberg.org";
          identityFile = [ "${home}/.ssh/id_codeberg" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "capuchin-us-ne" = {
          hostname = "5.161.179.69";
          identityFile = [ "${home}/.ssh/id_codeberg" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        kogatana = {
          hostname = "kogatana";
          identityFile = [ "${home}/.ssh/id_codeberg" ];
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
        "*" = {
          addKeysToAgent = "yes";
          compression = false;
          controlMaster = "no";
          controlPath = "${home}/.config/ssh/master-%r@%n:%p";
          controlPersist = "no";
          forwardAgent = true;
          hashKnownHosts = false;
          identitiesOnly = true;
          serverAliveCountMax = 3;
          serverAliveInterval = 0;
          userKnownHostsFile = "${home}/.config/ssh/known_hosts";
        };
        sk = {
          identityFile = [ "${home}/.config/ssh/id_ed25519_key_sk" ];
        };
      };
    };

    zsh = {
      enable = true;
      autosuggestion = {
        enable = true;
        strategy = [ "history" ];
      };
      history = {
        ignoreAllDups = true;
        ignoreSpace = true;
        size = 1000;
      };
      syntaxHighlighting.enable = true;
      autocd = true;
      enableCompletion = true;
      dotDir = "${home}/.config/zsh";
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      shellWrapperName = "fm";
    };
  };
}
