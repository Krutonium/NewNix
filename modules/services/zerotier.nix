{ ... }:
{
  flake.nixosModules.zerotier =
    { ... }:
    {
      services.zerotierone = {
        enable = true;
        joinNetworks = [ "b103a835d233ec24" ];
      };
    };
}
