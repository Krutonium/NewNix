{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.boot;
  installTarget = "/dev/sda";
  devices = [ "nodev" ];
  default = "saved";
in
{
  config = mkIf (cfg.bootloader == "bios") {
    boot = {
      loader = {
        grub = {
          device = installTarget;
          devices = devices;
          efiSupport = false;
          useOSProber = true;
          default = default;
          enable = true;
        };
      };
    };
  };
}
