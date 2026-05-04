{ ... }:
{
  flake.homeModules.packages-server =
    { osConfig, pkgs, lib, ... }:
    {
      config = lib.mkIf (osConfig.services.displayManager.gdm.enable == false) {
        home.packages = [ pkgs.atuin ];
      };
    };
}
