{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.users = {
    home-manager = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Should system be Home Manager Enabled
      '';
    };
    krutonium = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable user Krutonium
      '';
    };
  };
  imports = [ ./krutonium.nix ];
}