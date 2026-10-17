# Session variables that home-manager's `i18n` and `xdg.portal` modules
# contributed. Both are small enough to live here rather than in a module of
# their own.
{
  config,
  lib,
  osConfig,
  ...
}:
let

  glibcLocales = osConfig.i18n.glibcLocales;
  glibcVersion = toString glibcLocales.version;

  localeVars =
    if lib.versionAtLeast glibcVersion "2.27" then
      {
        LOCALE_ARCHIVE_2_27 = "${glibcLocales}/lib/locale/locale-archive";
      }
    else if lib.versionAtLeast glibcVersion "2.11" then
      {
        LOCALE_ARCHIVE_2_11 = "${glibcLocales}/lib/locale/locale-archive";
      }
    else
      { };
in
{
  config = lib.mkMerge [
    {
      system.session = {
        variables = localeVars;
        systemdVariables = localeVars;
      };
    }

    # The portal package is linked into the per-user profile, and D-Bus needs to
    # be told where to find it.
    (lib.mkIf osConfig.xdg.portal.enable {
      system.session = {
        variables.NIX_XDG_DESKTOP_PORTAL_DIR = "${config.home.profileDirectory}/share/xdg-desktop-portal/portals";
        systemdVariables.NIX_XDG_DESKTOP_PORTAL_DIR = "${config.home.profileDirectory}/share/xdg-desktop-portal/portals";
      };
    })
  ];
}
