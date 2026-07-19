{ ... }:
{
  flake.homeModules.packages-server =
    { osConfig, pkgs, lib, ... }:
    {
      config = lib.mkIf (osConfig.services.desktopManager.gnome.enable == false) {
        home.packages = [ pkgs.atuin ];
      };
    };
}
