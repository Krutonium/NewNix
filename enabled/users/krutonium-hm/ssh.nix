{ ... }:
{
  flake.homeModules.ssh =
    { ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            Compression = true;
            User = "krutonium";
          };
          "uSteamDeck" = {
            HostName = "10.9";
          };
          "uWebServer" = {
            HostName = "10.1";
          };
          "uGamingPC" = {
            HostName = "10.2";
          };
          "uServerHost" = {
            HostName = "10.3";
          };
          "uMsiLaptop" = {
            hostname = "10.0.0.5";
          };
          "darth" = {
            HostName = "195.35.113.15";
          };
        };
      };
    };
}
