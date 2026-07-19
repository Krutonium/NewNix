{ ... }:
{
  flake.nixosModules.avahi =
    { ... }:
    {
      services.avahi = {
        enable = true;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
          domain = true;
          hinfo = true;
          userServices = true;
        };
      };
    };
}
