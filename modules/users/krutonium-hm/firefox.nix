{ inputs, ... }:
{
  flake.homeModules.firefox =
    {
      pkgs,
      inputs,
      osConfig,
      config,
      lib,
      ...
    }:
    let
      pkgsUnfree = import inputs.nixpkgs {
        inherit (pkgs) system;
        config.allowUnfree = true;
      };
      nur = import inputs.nur {
        pkgs = pkgsUnfree;
        nurpkgs = pkgsUnfree;
      };
      addons = nur.repos.rycee.firefox-addons;

      forceEnabled =
        exts:
        builtins.listToAttrs (
          map (ext: {
            name = ext.addonId;
            value = {
              installation_mode = "force_installed";
            };
          }) exts
        );

      extensions = with addons; [
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
        twitch-auto-points
      ];

    in
    {
      config = lib.mkIf (osConfig.services.displayManager.gdm.enable == true) {
        programs.firefox = {
          enable = true;
          package = pkgs.unstable.firefox;
          policies.ExtensionSettings = forceEnabled extensions;
          configPath = "${config.xdg.configHome}/mozilla/firefox";
          profiles.krutonium = {
            extensions.packages = extensions;
            userChrome = ''
              /* Hide the "Firefox View" button by default */
              #firefox-view-button {
                display: none !important;
              }
              /* Hide the All Tabs Dropdown */
              #alltabs-button {
                display: none !important;
              }
              /* Compact the tab bar height */
              :root {
                --tab-min-height: 28px !important;
              }
              /* Hide the bookmarks toolbar star/heart icon in the URL bar - I don't use Bookmarks */
              #star-button-box {
                display: none !important;
              }
              /* Set Font to Ubuntu */
              * {
                  font-family: "Ubuntu";
              }

            '';
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
              "extensions.autoDisableScopes" = false;
              "extensions.startupScanScopes" = false;

              "browser.download.lastDir" = "/home/krutonium/Downloads";
              "extensions.pocket.enabled" = false;
              "browser.startup.homepage" = "about:newtab";
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
              "full-screen-api.warning.timeout" = 0; # Hide Fullscreen Warning
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
              "browser.toolbars.bookmarks.visibility" = "never";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            };
          };
        };
      };
    };

}
