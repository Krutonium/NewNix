{ config, pkgs, lib, ... }:
{
  networking.firewall.allowedTCPPorts = [ 32400 ];
  services.plex = {
    enable = true;
    openFirewall = true;
  };
}
