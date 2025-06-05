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
  config = mkIf (cfg.desktop == "pantheon") {
    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.pantheon.enable = true;
    };
  };
}
