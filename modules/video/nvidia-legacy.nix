{ ... }:
{
  flake.nixosModules.nvidia-legacy =
    { pkgs, config, ... }:
    {
      hardware = {
        graphics.enable = true;
        nvidia = {
          powerManagement = {
            enable = false;
          };
          package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
          open = false;
          nvidiaSettings = false;
        };
      };
      nixpkgs.config.cudaSupport = true;
    };
}
