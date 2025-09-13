{
  config,
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
          wayland.enable = true;
        };
      };
    };
  };
}
