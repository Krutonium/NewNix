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
  config = mkIf (cfg.displayManager == "lightdm") {
    services = {
      xserver = {
        enable = true;
        excludePackages = [ pkgs.xterm ];
        displayManager = {
          lightdm = {
            enable = true;
          };
        };
      };
    };
  };
}
