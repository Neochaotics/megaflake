{
  lib,
  config,
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
    xdg.mimeApps.defaultApplications = {
      "text/html" = [
        "firefox.desktop"
        "chromium.desktop"
      ];
      "x-scheme-handler/http" = [
        "firefox.desktop"
        "chromium.desktop"
      ];
      "x-scheme-handler/https" = [
        "firefox.desktop"
        "chromium.desktop"
      ];
      "x-scheme-handler/about" = [
        "firefox.desktop"
        "chromium.desktop"
      ];
      "x-scheme-handler/unknown" = [
        "firefox.desktop"
        "chromium.desktop"
      ];
    };

    programs = {
      # - https://mozilla.github.io/policy-templates/
      firefox = {
        enable = true;
        policies = {
          "AppAutoUpdate" = false;
          "AutofillAddressEnabled" = false;
          "AutofillCreditCardEnabled" = false;
          "BackgroundAppUpdate" = false;
          "CaptivePortal" = true;
          "Cookies" = {
            "AcceptThirdParty" = "from-visited";
            "Behavior" = "reject-tracker";
            "BehaviorPrivateBrowsing" = "reject-tracker";
            "RejectTracker" = true;
          };
          # "DefaultDownloadDirectory" = "${homeDir}/Downloads";
          "DisableAppUpdate" = true;
          "DisableDefaultBrowserAgent" = true;
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
          "DisplayBookmarksToolbar" = "newtab";
          "DisplayMenuBar" = "default-off";
          "DNSOverHTTPS" = {
            "Enabled" = true;
            "ProviderURL" = "https=//dns.quad9.net/dns-query";
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
          "NetworkPrediction" = false;
          "NewTabPage" = true;
          "NoDefaultBookmarks" = true;
          "OfferToSaveLogins" = false;
          "OverrideFirstRunPage" = "";
          "OverridePostUpdatePage" = "";
          "PasswordManagerEnabled" = false;
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
            "WhatsNew" = false;
            "ExtensionRecommendations" = true;
            "FeatureRecommendations" = false;
            "UrlbarInterventions" = false;
            "SkipOnboarding" = true;
            "MoreFromMozilla" = false;
            "Locked" = true;
          };
          "Preferences" = {
            "browser.aboutConfig.showWarning" = {
              Value = false;
              Status = "locked";
            };
            "browser.newtab.preload" = {
              Value = false;
              Status = "locked";
            };
            "browser.newtabpage.activity-stream.feeds.telemetry" = {
              Value = false;
              Status = "locked";
            };
            "geo.provider.use_geoclue" = {
              Value = false;
              Status = "locked";
            };
            "browser.region.update.enabled" = {
              Value = false;
              Status = "locked";
            };
            "app.update.auto" = {
              Value = false;
              Status = "locked";
            };
            "browser.discovery.enabled" = {
              Value = false;
              Status = "locked";
            };
            "extensions.htmlaboutaddons.recommendations.enabled" = {
              Value = false;
              Status = "locked";
            };
            "network.connectivity-service.enabled" = {
              Value = false;
              Status = "locked";
            };
            "browser.safebrowsing.malware.enabled" = {
              Value = false;
              Status = "locked";
            };
            "browser.safebrowsing.phishing.enabled" = {
              Value = false;
              Status = "locked";
            };
            "browser.tabs.crashReporting.sendReport" = {
              Value = false;
              Status = "locked";
            };
            "browser.cache.disk.enable" = {
              Value = false;
              Status = "locked";
            };
            "browser.safebrowsing.provider.google4.gethashURL" = {
              Value = "";
              Status = "locked";
            };
            "browser.safebrowsing.provider.google4.updateURL" = {
              Value = "";
              Status = "locked";
            };
            "browser.safebrowsing.provider.google.gethashURL" = {
              Value = "";
              Status = "locked";
            };
            "browser.safebrowsing.provider.google.updateURL" = {
              Value = "";
              Status = "locked";
            };
            "browser.safebrowsing.provider.google4.dataSharingURL" = {
              Value = "";
              Status = "locked";
            };
            "browser.safebrowsing.downloads.enabled" = {
              Value = false;
              Status = "locked";
            };
            "browser.safebrowsing.downloads.remote.enabled" = {
              Value = false;
              Status = "locked";
            };
            "browser.safebrowsing.downloads.remote.url" = {
              Value = "";
              Status = "locked";
            };
            "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = {
              Value = false;
              Status = "locked";
            };
            "browser.safebrowsing.downloads.remote.block_uncommon" = {
              Value = false;
              Status = "locked";
            };
            "network.prefetch-next" = {
              Value = false;
              Status = "locked";
            };
            "network.dns.disablePrefetch" = {
              Value = false;
              Status = "locked";
            };
            "network.predictor.enabled" = {
              Value = false;
              Status = "locked";
            };
            "network.http.speculative-parallel-limit" = {
              Value = 0;
              Status = "locked";
            };
            "browser.places.speculativeConnect.enabled" = {
              Value = false;
              Status = "locked";
            };
            "network.dns.disableIPv6" = {
              Value = true;
              Status = "locked";
            };
            "browser.urlbar.trimURLs" = {
              Value = false;
              Status = "locked";
            };
            "browser.urlbar.speculativeConnect.enabled" = {
              Value = false;
              Status = "locked";
            };
            "browser.sessionstore.privacy_level" = {
              Value = 2;
              Status = "locked";
            };
            "browser.sessionstore.resume_from_crash" = {
              Value = false;
              Status = "locked";
            };
            "browser.shell.shortcutFavicons" = {
              Value = false;
              Status = "locked";
            };
            "dom.security.https_only_mode_send_http_background_request" = {
              Value = false;
              Status = "locked";
            };
            "browser.xul.error_pages.expert_bad_cert" = {
              Value = true;
              Status = "locked";
            };
            "network.http.referer.XOriginPolicy" = {
              Value = 2;
              Status = "locked";
            };
            "network.http.referer.XOriginTrimmingPolicy" = {
              Value = 2;
              Status = "locked";
            };
            "media.peerconnection.ice.proxy_only_if_behind_proxy" = {
              Value = true;
              Status = "locked";
            };
            "media.peerconnection.ice.default_address_only" = {
              Value = true;
              Status = "locked";
            };
            "media.peerconnection.ice.no_host" = {
              Value = true;
              Status = "locked";
            };
            "media.eme.enabled" = {
              Value = false;
              Status = "locked";
            };
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "locked";
            };
            "privacy.resistFingerprinting" = {
              Value = true;
              Status = "locked";
            };
            "privacy.window.maxInnerWidth" = {
              Value = 1600;
              Status = "locked";
            };
            "privacy.window.maxInnerHeight" = {
              Value = 900;
              Status = "locked";
            };
            "browser.display.use_system_colors" = {
              Value = true;
              Status = "locked";
            };
          };
          "UseSystemPrintDialog" = true;
        };
      };
    };
  };
}
