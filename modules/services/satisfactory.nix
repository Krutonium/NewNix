{ ... }:
{
  flake.nixosModules.satisfactory =
    { ... }:
    {
      services.satisfactory = {
        enable = true;
        dataDir = "/servers/satisfactory";
      };
    };
}
