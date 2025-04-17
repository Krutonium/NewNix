{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
{
  options.sys.custom = {
    ddcutil = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable ddcutil.
      '';
    };
    ddcutil_nvidiaFix = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable ddcutil nvidia fix.
      '';
    };
    alvr = mkOption {
      type = types.bool;
      default = false;
      description = ''
        alvr
      '';
    };
  };
  imports = [
    ./ddcutil.nix
    ./ddcutil_nvidiaFix.nix
    ./ALVR.nix
  ];
}
