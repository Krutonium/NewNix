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
        user = "krutonium";
        compression = true;
        userKnownHostsFile = "/dev/null";
      };
      "uWebServer" = {
        hostname = "10.1";
        compression = true;
        userKnownHostsFile = "/dev/null";
      };
      "uGamingPC" = {
        hostname = "10.2";
        compression = true;
        userKnownHostsFile = "/dev/null";
      };
      "uRenderPC" = {
        hostname = "10.3";
        compression = true;
        userKnownHostsFile = "/dev/null";
      };
      "darth" = {
        hostname = "195.35.113.15";
        compression = true;
        userKnownHostsFile = "/dev/null";
      };
      "uServerHost" = {
        hostname = "10.0.0.3";
        compression = true;
        userKnownHostsFile = "/dev/null";
      };
    };
    extraConfig = ''
      StrictHostKeyChecking no
    '';
  };
}
