{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "kde") {
    services = {
      xserver = {
        enable = true;
        desktopManager = {
          plasma6 = {
            enable = true;
          };
        };
      };
    };
    security = {
      rtkit = {
        enable = true;
      };
    };
    environment.systemPackages = [ pkgs.flameshot ];
  };
}
