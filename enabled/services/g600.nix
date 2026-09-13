{ inputs, ... }:
{
  flake.nixosModules.g600 =
    { lib, ... }:
    {
      imports = [
        inputs.g600-key-remap-daemon.nixosModules.g600-key-remap
      ];
      systemd.services.g600-key-remap.serviceConfig = {
        TimeoutStopSec = "5s";
      };
      virtualisation.vmVariant = {
        services.g600-key-remap.enable = lib.mkForce false;
      };
    };
}
