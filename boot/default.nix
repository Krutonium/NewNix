{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.boot = {
    bootloader = mkOption {
      type = types.enum [ "uefi" "bios" ];
      default = "uefi";
      description = ''
        Your system's firmware.
      '';
    };
    plymouth_enabled = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable plymouth.
      '';
    };
    plymouth_theme = mkOption {
      type = types.str;
      default = "bgrt";
      description = ''
        The plymouth theme to use.
      '';
    };
  };
  imports = [ ./uefi.nix ./bios.nix ];
}
