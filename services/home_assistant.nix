{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.homeAssistant == true) {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "met"
        "radio_browser"
      ];
      config = {
        default_config = {};
        http = {
          server_host = "::1";
          trusted_proxies = "::1";
          use_x_forwarded_for = true;
        };
      };
    };
  };
}