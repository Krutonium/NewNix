{ ... }:
{
  flake.nixosModules.zswap =
    { lib, ... }:
    {
      boot.zswap = {
        enable = true;
        maxPoolPercent = 25;
        shrinkerEnabled = true;
      };
      virtualisation.vmVariant = {
        # Only applied when building the VM variant of this system
        zramSwap.enable = lib.mkForce false;
        boot.zswap.enable = lib.mkForce false;
        swapDevices = lib.mkForce [
          {
            device = "/swapfile";
            size = 2 * 1024; # small throwaway swap, satisfies the zswap backing-store assertion
          }
        ];
      };
    };
}
