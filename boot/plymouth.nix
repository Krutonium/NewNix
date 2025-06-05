{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.boot;
in
{
  config = mkIf (cfg.plymouth_enabled == true) {
    environment.systemPackages = [ pkgs.plymouth ];
    boot.plymouth.enable = cfg.plymouth_enabled;
    #boot.plymouth.theme = lib.mkForce cfg.plymouth_theme;
    #boot.initrd.availableKernelModules = [ "plymouthd" ];
  };
}
