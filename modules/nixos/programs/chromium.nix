{ lib, pkgs, config, ... }:
let
  cfg = config.qm.nixos.programs.chromium;
in
{
  options.qm.nixos.programs.chromium = {
    enable = lib.mkEnableOption "Chromium NixOS-level hardened configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      extraOpts = {
        # Nuclear option: profile lives entirely in memory, nothing touches disk
        ForceEphemeralProfiles = true;

        # Force incognito mode at the policy level
        IncognitoModeAvailability = 2;
        BrowserGuestModeEnabled = false;

        # Wipe everything on exit
        ClearBrowsingDataOnExitList = [
          "cookies"
          "cache"
          "history"
          "passwords"
          "autofill"
          "site_settings"
          "hosted_apps_data"
        ];
        SavingBrowserHistoryDisabled = true;
        DefaultCookiesSetting = 4;  # session-only
        PasswordManagerEnabled = false;
        AutoFillEnabled = false;
        SyncDisabled = true;

        # Always start blank — no session restore, no homepage
        RestoreOnStartup = 0;
        HomepageLocation = "about:blank";
        HomepageIsNewTabPage = false;
        NewTabPageLocation = "about:blank";

        # Kill data-leaky features
        SearchSuggestEnabled = false;
        NetworkPredictionOptions = 2;  # disable prediction
      };
    };
  };
}
