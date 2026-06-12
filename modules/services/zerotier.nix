{ ... }:
{
  flake.nixosModules.zerotier =
    { ... }:
    {
      services.zerotierone = {
        enable = true;
        joinNetworks = [ "b103a835d233ec24" ];
      };
      systemd.network.links."10-zerotier" = {
        matchConfig.OriginalName = "ztqtizxwpw";
        linkConfig.Name = "zt0";
      };
    };
}
