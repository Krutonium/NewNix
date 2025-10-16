{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.krutonium = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        ublock-origin
        clearurls
        augmented-steam
        behind-the-overlay-revival
        betterttv
        darkreader
        consent-o-matic
        reddit-enhancement-suite
        sponsorblock
        return-youtube-dislikes
        skip-redirect
        duckduckgo-privacy-essentials
        localcdn
        old-reddit-redirect
        auto-tab-discard
        don-t-fuck-with-paste
        enhanced-github
        faststream
        twitch-auto-points
      ];
      search = {
        engines = {
          KruSearch = {
            name = "KruSearch";
            urls = [ { template = "https://search.krutonium.ca/search?q={searchTerms}&language=en"; } ];
            iconMapObj."16" = "https://search.krutonium.ca/favicon.ico";
            definedAliases = [ "@ks" ];
          };
        };
        default = "KruSearch";
        force = true;
      };

      settings = {
        "browser.download.lastDir" = "/home/krutonium/Downloads";
        "extensions.pocket.enabled" = false;
        "browser.startup.homepage" = "about:newtab";
        "extensions.autoDisableScopes" = false;
        "signon.rememberSignons" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.sessionstore.resume_from_crash" = true;
        "browser.sessionstore.resuming_after_os_restart" = true;
        "browser.link.open_newwindow.restriction" = 0;
        "browser.tabs.groups.enabled" = false;

        "browser.tabs.groups.smart.enabled" = false;
        "browser.tabs.groups.smart.userEnabled" = false;

        "browser.cache.memory.enable" = false;
        "image.jxl.enabled" = true;
        "dom.block_download_insecure" = false;
        "browser.compactmode.show" = true;
        "browser.uidensity" = "1";

        "browser.tabs.insertAfterCurrent" = false; # decided I didn't like it

        "browser.ml.enabled" = false;
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.menu" = false;
        "browser.ml.chat.shortcuts" = false;
        "browser.ml.chat.shortcuts.custom" = false;
        "extensions.ml.enabled" = false;
        "browser.ml.chat.page" = false;
        "browser.ml.chat.page.footerBadge" = false;
        "browser.ml.chat.page.menuBadge" = false;
        "browser.mk.linkPreview.enable" = false;
        "browser.ml.chat.sidebar" = false;
        "browser.ml.chat.onboard.config" = "fuck you";
        "browser.ml.checkForMemory" = false;
        "browser.ml.linkPreview.shift" = false;
        "browser.ml.linkPreview.onboardingTimes" = 0;
        "browser.urlbar.trimURLs" = false;
      };
    };
  };
}
