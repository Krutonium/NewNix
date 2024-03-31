{ config, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    profiles."krutonium" = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
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
        bypass-paywalls-clean
        don-t-fuck-with-paste
        enhanced-github
        faststream
      ];
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

        "browser.cache.memory.enable" = false;
        "image.jxl.enabled" = true;
        "dom.block_download_insecure" = false;
        "browser.compactmode.show" = true;
        "browser.uidenity" = "1";       
        
      };
    };
  };
}
