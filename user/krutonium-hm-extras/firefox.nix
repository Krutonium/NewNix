{ config, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    profiles."default" = {
      extensions = with pkgs.firefox-addons; [
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
        "browser.startup.homepage" = "https://nixos.org";
      };
    };
  };
}