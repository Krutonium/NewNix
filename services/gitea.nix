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
      settings = {
        server = {
          ROOT_URL = "https://gitea.krutonium.ca/";
          HTTP_PORT = 3001;
          DOMAIN = "gitea.krutonium.ca";
        };
        service = {
          DISABLE_REGISTRATION = true;
          COOKIE_SECURE = true;
        }
        indexer = {
          REPO_INDEXER_ENABLED = true;
        };
      };
      appName = "Krutonium's Gitea Service";
      database = {
        type = "sqlite3";
      };
    };
  };
}
