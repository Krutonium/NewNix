{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.gitea == true) {
    services.forgejo = {
      enable = true;
      # Forgejo is a dropin replacement
      #package = pkgs.forgejo;
      #package = pkgs.gitea;
      package = pkgs.unstable.forgejo;
      stateDir = "/media2/forgejo/repos";
      settings = {
        server = {
          ROOT_URL = "https://git.krutonium.ca/";
          HTTP_PORT = 3001;
          DOMAIN = "git.krutonium.ca";
        };
        "attachment" = {
          MAX_SIZE = 1000;
        };
        "git.timeout" = {
          DEFAULT = 720;
          MIGRATE = 30000;
          MIRROR = 72000;
          CLONE = 30000;
          PULL = 30000;
          GC = 60;
        };
        service = {
          DISABLE_REGISTRATION = true;
          #COOKIE_SECURE = true;
        };
        indexer = {
          REPO_INDEXER_ENABLED = true;
        };
        DEFAULT = {
          APP_NAME = "Krutonium's Forgejo Service";
        };
        Federation = {
          Enabled = true;
        };
      };
      database = {
        type = "sqlite3";
        user = "gitea";
        name = "gitea";
      };
    };
  };
}
