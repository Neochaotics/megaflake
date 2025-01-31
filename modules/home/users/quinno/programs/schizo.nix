{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.schizo;
in
{
  imports = [ inputs.schizofox.homeManagerModule ];
  options.cm.home.users.quinno.programs.schizo = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {

    programs.schizofox = {
      enable = true;

      search = {
        defaultSearchEngine = "Brave";
        removeEngines = [
          "Google"
          "Bing"
          "Amazon.com"
          "eBay"
          "Twitter"
          "Wikipedia"
        ];
        searxUrl = "https://searx.be";
        searxQuery = "https://searx.be/search?q={searchTerms}&categories=general";
      };

      security = {
        sanitizeOnShutdown.enable = true;
        sandbox.enable = true;
        #userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:106.0) Gecko/20100101 Firefox/106.0";
      };

      misc = {
        drmFix = true;
        disableWebgl = false;
        contextMenu.enable = true;
      };

      extensions = {
        simplefox.enable = true;
        darkreader.enable = true;
      };
    };

  };
}
