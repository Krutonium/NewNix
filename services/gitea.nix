{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.gitea == true) {
    services.gitea = {
      enable = true;
      appName = "Krutonium's Gitea Service";
      database = {
        type = "sqlite3";
      };
      domain = "gitea.krutonium.ca";
      rootUrl = "https://gitea.krutonium.ca/";
      httpPort = 3001;
      settings.service = {
        DISABLE_REGISTRATION = true;
        COOKIE_SECURE = true;
      };
      extraConfig = ''
        [indexer]
        REPO_INDEXER_ENABLED = true
      ''
        };
    }
