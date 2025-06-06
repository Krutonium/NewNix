{ ... }:
{
  programs.ssh = {
    enable = true;
    compression = true;
    userKnownHostsFile = "/dev/null";
    matchBlocks = {
      "deck" = {
        hostname = "10.9";
        user = "krutonium";
      };
      "uWebServer" = {
        hostname = "10.1";
      };
      "uGamingPC" = {
        hostname = "10.2";
      };
      "uRenderPC" = {
        hostname = "10.3";
      };
      "darth" = {
        hostname = "195.35.113.15";
      };
      "uServerHost" = {
        hostname = "10.0.0.3";
      };
    };
    extraConfig = ''
      StrictHostKeyChecking no
    '';
  };
}
