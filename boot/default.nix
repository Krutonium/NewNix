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
  };
  imports = [ ./uefi.nix ./bios.nix ];
}