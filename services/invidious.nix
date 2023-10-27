{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.invidious == true) {
    services.invidious = {
      enable = true;
      domain = "tube.krutonium.ca";
      nginx.enable = true;
    };
  };
}
