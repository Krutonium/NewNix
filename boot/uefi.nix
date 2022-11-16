{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.boot;
  mountPoint = "/boot";
  devices = "nodev";
  default = "saved";
in
{
  config = mkIf (cfg.bootloader == "uefi") {
    boot = {
      loader = {
        efi = {
          efiSysMountPoint = mountPoint;
          canTouchEfiVariables = true;
        };
        grub = {
          devices = [ devices ];
          efiSupport = true;
          useOSProber = true;
          default = default;
          enable = true;
        };
      };
    };
  };
}
