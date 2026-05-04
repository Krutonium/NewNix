# modules/assets.nix
{ ... }:
{
  flake.nixosModules.assets =
    { lib, ... }:
    {
      key = "krutonium/nixosModules/assets"; #allow merges from multiple imports
      options.assets = {
        superMenuLogo = lib.mkOption {
          type = lib.types.path;
          default = ./supermenu.png;
        };
        wallpaper = lib.mkOption {
          type = lib.types.path;
          default = ./wallpaper.jpg;
        };
        profile = lib.mkOption {
          type = lib.types.path;
          default = ./profile.png;
        };
      };
    };
}
