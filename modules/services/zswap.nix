{ ... }:
{
  flake.nixosModules.zswap =
    { ... }:
    {
      boot = {
        kernelParams = [
          # REPLACE WITH `boot.zswap` once 26.05 drops
          "zswap.enabled=1"
          "zswap.compressor=zstd"
          "zswap.max_pool_percent=30"
          "zswap.shrinker_enabled=1"
        ];
      };
    };
}
