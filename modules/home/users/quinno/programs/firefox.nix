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
          "UseSystemPrintDialog" = true;
        };
        profiles.default = {
          isDefault = true;
          settings = {
            "beacon.enabled" = false;
            "browser.contentblocking.category" = "strict";
            "browser.display.os-zoom-behavior" = 1;
            "browser.download.dir" = "${config.home.homeDirectory}/download";
            "browser.newtabpage.enabled" = false; # Blank new tab page.
            "browser.safebrowsing.appRepURL" = "";
            "browser.safebrowsing.malware.enabled" = false;
            "browser.search.hiddenOneOffs" = "Google,Yahoo,Bing,Amazon.com,Twitter";
            "browser.search.suggest.enabled" = false;
            "browser.send_pings" = false;
            "browser.tabs.closeWindowWithLastTab" = false;
            "browser.uidensity" = 1; # Dense.
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "browser.urlbar.speculativeConnect.enabled" = false;
            "devtools.theme" = "dark";
            "dom.battery.enabled" = false;
            "dom.security.https_only_mode" = true;
            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.supported" = false;
            "extensions.unifiedExtensions.enabled" = false;
            "general.smoothScroll" = false;
            "geo.enabled" = false;
            "gfx.webrender.all" = true;
            "layout.css.devPixelsPerPx" = 1;
            # Follow system color theme.
            "layout.css.prefers-color-scheme.content-override" = 2;
            "media.ffmpeg.vaapi.enabled" = true;
            "media.navigator.enabled" = false;
            "media.video_stats.enabled" = false;
            "network.IDN_show_punycode" = true;
            "network.allow-experiments" = false;
            "network.dns.disablePrefetch" = true;
            "network.http.referer.XOriginPolicy" = 1;
            "network.http.referer.XOriginTrimmingPolicy" = 1;
            "network.http.referer.trimmingPolicy" = 1;
            "network.prefetch-next" = false;
            "permissions.default.shortcuts" = 2; # Don't steal my shortcuts!
            "privacy.donottrackheader.enabled" = true;
            "privacy.donottrackheader.value" = 1;
            "privacy.firstparty.isolate" = true;
            "signon.rememberSignons" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "ui.textScaleFactor" = 100;

            # Fully disable Pocket. See
            # https://www.reddit.com/r/linux/comments/zabm2a.
            "extensions.pocket.enabled" = false;
            "extensions.pocket.api" = "0.0.0.0";
            "extensions.pocket.loggedOutVariant" = "";
            "extensions.pocket.oAuthConsumerKey" = "";
            "extensions.pocket.onSaveRecs" = false;
            "extensions.pocket.onSaveRecs.locales" = "";
            "extensions.pocket.showHome" = false;
            "extensions.pocket.site" = "0.0.0.0";
            "browser.newtabpage.activity-stream.pocketCta" = "";
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "services.sync.prefs.sync.browser.newtabpage.activity-stream.section.highlights.includePocket" =
              false;
          };
          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
            auto-tab-discard
            cookie-autodelete
            darkreader
            libredirect
            link-cleaner
            linkhints
            skip-redirect
            ublock-origin
          ];
        };
      };
    };
  };
}
