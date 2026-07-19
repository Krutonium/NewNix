{ ... }:
{
  flake.nixosModules.zswap =
    { ... }:
    {
      boot.zswap = {
        enable = true;
        maxPoolPercent = 25;
        shrinkerEnabled = true;
      };
    };
}
