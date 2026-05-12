{ inputs, ... }:
{
  flake.nixosModules.nixflix =
    { config, ... }:
    {
      imports = [ inputs.nixflix.nixosModules.default ];
      sops.secrets = {
        sonaar_apikey = {
          owner = "sonarr";
          group = "sonarr";
          mode = "0400";
        };
        sonaar_password = {
          owner = "sonarr";
          group = "sonarr";
          mode = "0400";
        };
        radaar_apikey = {
          owner = "radaar";
          group = "radarr";
          mode = "0400";
        };
        radaar_password = {
          owner = "radaar";
          group = "radaar";
          mode = "0400";
        };
        prowlaar_apikey = {
          owner = "prowlarr";
          group = "prowlarr";
          mode = "0400";
        };
        prowlaar_password = {
          owner = "prowlarr";
          group = "prowlarr";
          mode = "0400";
        };
      };
      nixflix = {
        enable = true;
        mediaDir = "/media2/";
        stateDir = "/media2/.nixflix_state";
        nginx.enable = true;
        postgres.enable = true;
        sonaar = {
          enable = true;
          config = {
            apiKey = config.sops.secrets.sonaar_apikey.path;
            hostConfig.password = config.sops.secrets.sonaar_password.path;
          };
        };
        radaar = {
          enable = true;
          config = {
            apiKey = config.sops.secrets.radaar_apikey.path;
            hostConfig.password = config.sops.secrets.radaar_password.path;
          };
        };
        prowlarr = {
          enable = true;
          config = {
            apiKey = config.sops.secrets.prowlaar_apikey.path;
            hostConfig.password = config.sops.secrets.prowlaar_password.path;
          };
        };
      };
    };
}
