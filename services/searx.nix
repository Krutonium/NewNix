{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.searx == true) {
    networking.firewall.allowedTCPPorts = [ 631 ];
    services.searx = {
      environmentFile = "/etc/secrets/searx_secret";
      enable = true;
      redisCreateLocally = true;
      settings = {
        general = {
          debug = false;
          instance_name = "KruSearch";
          donation_url = false;
          contact_url = false;
          privacypolicy_url = false;
          enable_metrics = false;
        };
        ui = {
          static_use_hash = true;
          default_locale = "en";
          query_in_title = true;
          infinite_scroll = true;
          center_alignment = true;
          default_theme = "simple";
          theme_args.simple_style = "auto";
          search_on_category_select = true;
        };
        search = {
          safe_search = 1;
          autocomplete_min = 2;
          autocomplete = "duckduckgo";
          ban_time_on_fail = 5;
          max_ban_time_on_fail = 120;
        };

        server = {
          port = 60613;
          bind_address = "127.0.0.1";
          base_url = "https://search.krutonium.ca";
          limiter = true;
          public_instance = true;
          image_proxy = false;
          method = "GET";
        };

        outgoing = {
          request_timeout = 5.0;
          max_request_timeout = 15.0;
          pool_connections = 100;
          pool_maxsize = 15;
          enable_http2 = true;
        };

        # Rate Limiting
        limiterSettings = {
          real_ip = {
            x_for = 1;
            ipv4_prefix = 32;
            ipv6_prefix = 56;
          };
          botdetection = {
            ip_limit = {
              filter_link_local = true;
              link_token = true;
            };
          };
        };

        enabled_plugins = [
          "Basic Calculator"
          "Hash plugin"
          "Tor check plugin"
          "Open Access DOI rewrite"
          "Hostnames plugin"
          "Unit converter plugin"
          "Tracker URL remover"
        ];

        engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
          "duckduckgo" = {
            disabled = false;
            weight = 4;
          };
          "duckduckgo images".disabled = false;
          "ddg definitions" = {
            disabled = false;
            weight = 2;
          };
          "brave".disabled = false;
          "brave.images".disabled = true;
          "bing".disabled = false;

          "wikibooks".disabled = false;
          "bing images".disabled = false;

          "flickr".disabled = true;
          "imgur".disabled = true;
          "pinterest".disabled = true;
          "wikicommons.images".disabled = false;
          "youtube".disabled = false;
          "google news".disabled = false;
        };
      };
    };
  };
}
