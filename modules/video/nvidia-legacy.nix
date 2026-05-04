{ ... }:
{
  flake.nixosModules.nvidia-legacy =
    { pkgs, config, ... }:
    {
      hardware = {
        graphics.enable = true;
        nvidia = {
          powerManagement = {
            enable = true;
          };
          package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
          open = false;
          nvidiaSettings = true;
          modesetting.enable = true;
        };
      };
      nixpkgs.config.cudaSupport = true;
    };
}
