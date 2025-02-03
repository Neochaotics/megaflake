{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.firefox;
in
{
  options.cm.home.users.quinno.programs.firefox = {
    enable = lib.mkEnableOption "Firefox browser configuration";
  };
  config = lib.mkIf cfg.enable {
    programs = {
      chromium.enable = true;
      firefox = {
        enable = true;
        package = pkgs.firefox;
        policies = {
          "AppAutoUpdate" = false;
          "AutofillAddressEnabled" = false;
          "AutofillCreditCardEnabled" = false;
          "BackgroundAppUpdate" = false;
          # "CaptivePortal" = true;
          "DisableAppUpdate" = true;
          "DisableBuiltinPDFViewer" = true;
          "DisableFeedbackCommands" = true;
          "DisableFirefoxAccounts" = true;
          "DisableFirefoxScreenshots" = true;
          "DisableFirefoxStudies" = true;
          "DisableFormHistory" = true;
          "DisablePasswordReveal" = true;
          "DisablePocket" = true;
          "DisableProfileImport" = true;
          "DisableSafeMode" = true;
          "DisableSetDesktopBackground" = true;
          "DisableSystemAddonUpdate" = true;
          "DisableTelemetry" = true;
          "DisplayMenuBar" = "default-off";
          "DNSOverHTTPS" = {
            "Enabled" = true;
            "ProviderURL" = "https://dns.quad9.net/dns-query";
            "Locked" = true;
          };
          "DontCheckDefaultBrowser" = true;
          "EnableTrackingProtection" = {
            "Value" = true;
            "Locked" = true;
            "Cryptomining" = true;
            "Fingerprinting" = true;
            "EmailTracking" = true;
          };
          "EncryptedMediaExtensions" = {
            "Enabled" = true;
            "Locked" = true;
          };
          "ExtensionUpdate" = true;
          "FirefoxHome" = {
            "Search" = false;
            "TopSites" = false;
            "SponsoredTopSites" = false;
            "Highlights" = false;
            "Pocket" = false;
            "SponsoredPocket" = false;
            "Snippets" = false;
            "Locked" = true;
          };
          "FirefoxSuggest" = {
            "WebSuggestions" = false;
            "SponsoredSuggestions" = false;
            "ImproveSuggest" = false;
            "Locked" = true;
          };
          "HardwareAcceleration" = true;
          "Homepage" = {
            "Locked" = true;
            "StartPage" = "none";
          };
          "HttpsOnlyMode" = "force_enabled";
          "InstallAddonsPermission" = {
            "Default" = false;
          };
          "ManualAppUpdateOnly" = true;
          "NetworkPrediction" = false;
          "NewTabPage" = true;
          "NoDefaultBookmarks" = true;
          "OfferToSaveLogins" = false;
          "OverrideFirstRunPage" = "";
          "OverridePostUpdatePage" = "";
          "PasswordManagerEnabled" = false;
          "PDFjs" = {
            "Enabled" = false;
            "EnablePermissions" = false;
          };
          "PopupBlocking" = {
            "Default" = true;
          };
          "Permissions" = {
            "Camera" = {
              "BlockNewRequests" = false;
              "Locked" = true;
            };
            "Microphone" = {
              "BlockNewRequests" = false;
              "Locked" = true;
            };
            "Location" = {
              "BlockNewRequests" = true;
              "Locked" = true;
            };
            "Notifications" = {
              "BlockNewRequests" = true;
              "Locked" = true;
            };
            "Autoplay" = {
              "Default" = "block-audio-video";
              "Locked" = true;
            };
          };
          "PictureInPicture" = {
            "Enabled" = false;
            "Locked" = true;
          };
          "PostQuantumKeyAgreementEnabled" = true;
          "PrintingEnabled" = true;
          "SearchBar" = "unified";
          "SearchSuggestEnabled" = false;
          "ShowHomeButton" = false;
          "StartDownloadsInTempDirectory" = true;
          "SanitizeOnShutdown" = {
            "Cache" = true;
            "Cookies" = true;
            "History" = true;
            "Sessions" = true;
            "SiteSettings" = true;
            "Locked" = true;
          };
          "UserMessaging" = {
            # "WhatsNew" = false; Deprecated
            "ExtensionRecommendations" = false;
            "FeatureRecommendations" = false;
            "UrlbarInterventions" = false;
            "SkipOnboarding" = true;
            "MoreFromMozilla" = false;
            "FirefoxLabs" = false;
            "Locked" = true;
          };
          "UseSystemPrintDialog" = true;
          "Preferences" = {
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "widget.use-xdg-desktop-portal.location" = 0;
            "widget.use-xdg-desktop-portal.mime-handler" = 1;
            "widget.use-xdg-desktop-portal.open-uri" = 1;
            "widget.use-xdg-desktop-portal.settings" = 1;

          };
        };
        profiles.default = {
          isDefault = true;
          settings = {
            "browser.search.defaultenginename" = "DuckDuckGo";
            "browser.search.order.1" = "DuckDuckGo";
          };
          search = {
            force = true;
            default = "Brave";
            privateDefault = "Brave";
            order = [
              "Brave"
              "DuckDuckGo"
            ];
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
              "Bing".metaData.hidden = true;
              "Google".metaData.hidden = true;
              "Bookmarks".metaData.hidden = true;
              "LibRedirect".metaData.hidden = true;
            };
          };
          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
            auto-tab-discard
            cookie-autodelete
            darkreader
            libredirect
            linkhints
            skip-redirect
            ublock-origin
            bitwarden
            aria2-integration
          ];
        };
      };
    };
  };
}
