{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        user = "krutonium";
        compression = true;
      };
      "deck" = {
        hostname = "10.9";
        user = "deck";
        compression = true;
      };
      "uWebServer" = {
        hostname = "10.1";
        compression = true;
      };
      "uGamingPC" = {
        hostname = "10.2";
        compression = true;
      };
      "uRenderPC" = {
        hostname = "10.3";
        compression = true;
      };
      "darth" = {
        hostname = "195.35.113.15";
        compression = true;
      };
      "uServerHost" = {
        hostname = "10.0.0.3";
        compression = true;
      };
    };
    extraConfig = ''
      StrictHostKeyChecking no
    '';
  };
}
