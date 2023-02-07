{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.custom = {
    ddcutils = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Your desktop of choice.
      '';
    };
  };
  imports = [ ./ddcutils.nix ];
}
