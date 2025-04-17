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
  config = mkIf (cfg.displayManager == "sddm") {
    services = {
      xserver.enable = true;
      displayManager = {
        sddm = {
          enable = true;
        };
        autoLogin = {
          user = "krutonium";
          enable = true;
        };
      };
    };
  };
}
