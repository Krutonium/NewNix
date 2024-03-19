{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    compression = true;
    userKnownHostsFile = "/dev/null";
    matchBlocks = {
      "deck" = {
        hostname = "10.9";
        user = "deck";
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
    };
    extraConfig = ''
      StrictHostKeyChecking no
    '';
  };
}
