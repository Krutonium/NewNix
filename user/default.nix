{
  lib,
  ...
}:
with lib;
with builtins;
{
  options.sys.users = {
    krutonium = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable user Krutonium
      '';
    };
    root = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable root via PubKeyAuth
      '';
    };
    kea = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable user Kea
      '';
    };
  };
  options.sys.roles = {
    server = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable gameserver host account
      '';
    };
    desktop = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables Desktop Tweaks
      '';
    };
  };
  imports = [
    ./krutonium.nix
    ./root.nix
    ./kea.nix
    ./gameserver.nix
  ];
}
