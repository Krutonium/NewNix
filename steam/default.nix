{
  lib,
  ...
}:
with lib;
with builtins;
{
  options.sys.steam = {
    steam = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Steam
      '';
    };
  };
  imports = [ ./steam.nix ];
}
