{
  pkgs,
  ...
}:
let
  elementWebConfig = pkgs.writeText "element-config.json" (
    builtins.toJSON {
      brand = "Freedchat";
      default_server_name = "matrix.org";
      disable_guests = true;
      disable_3pid_login = true;
      disable_login_language_selector = true;
      show_labs_settings = true;
      force_verification = true;
      enable_presence_by_hs_url = {
        "https://matrix.org" = false;
        "https://matrix-client.matrix.org" = false;
      };
      integrations_ui_url = null;
      integrations_rest_url = null;
      integrations_widgets_urls = null;
      features = {
        feature_group_calls = true;
        feature_element_call_video_rooms = true;
        feature_video_rooms = true;
      };
      element_call = {
        use_exclusively = true;
        brand = "Freedpom Call";
      };
      jitsi = {
        preferred_domain = null;
      };
      setting_defaults = {
        "UIFeature.urlPreviews" = false;
        "UIFeature.shareQrCode" = false;
        "UIFeature.shareSocial" = false;
        "UIFeature.widgets" = false;
        "UIFeature.feedback" = false;
        "UIFeature.identityServer" = false;
        "UIFeature.thirdPartyId" = false;
        "UIFeature.advancedEncryption" = true;
        "UIFeature.advancedSettings" = true;
        "UIFeature.roomHistorySettings" = true;
        urlPreviewsEnabled = false;
        webRtcAllowPeerToPeer = false;
        enableEventIndexing = false;
        showAvatarChanges = false;
        showDisplaynameChanges = false;
        showJoinLeaves = false;
      };
    }
  );
in
{
  environment.systemPackages = with pkgs; [
    pavucontrol
    podman-compose
    prismlauncher
    r2modman
    vscodium
    netbird
    (element-desktop.override { commandLineArgs = "--config ${elementWebConfig}"; })
    me3
  ];
}
