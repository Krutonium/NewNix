{ ... }:
{
  flake.nixosModules.plex =
    { pkgs, ... }:
    {
      systemd.services.plex.serviceConfig.TimeoutStopSec = "10s";
      services.plex = {
        enable = true;
        openFirewall = true;
        package = pkgs.plex;
      };
    };
}