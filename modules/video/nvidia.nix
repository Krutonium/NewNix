{ ... }:
{
  flake.nixosModules.nvidia =
    { pkgs, config, ... }:
    {
      hardware = {
        graphics.enable = true;
        nvidia = {
          powerManagement = {
            enable = true;
          };
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          prime.offload.enable = false;
          open = true;
          nvidiaSettings = true;
          modesetting.enable = true;
        };
      };
      nixpkgs.config.cudaSupport = true;
    };
}
