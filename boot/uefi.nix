{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.boot;
  #mountPoint = "/boot";
  devices = "nodev";
  default = "saved";
in
{
  config = mkIf (cfg.bootloader == "uefi") {
    boot = {
      loader = {
        efi = {
          efiSysMountPoint = cfg.uefiPath;
          canTouchEfiVariables = true;
        };
        grub = {
          devices = [ devices ];
          efiSupport = true;
          useOSProber = true;
          default = default;
          enable = true;
          memtest86.enable = true;
          extraFiles = {
            "netbootxyz.efi" = "${pkgs.netbootxyz-efi}";
          };
          extraEntries = ''
            title iPXE
              chainloader /netbootxyz.efi
          '';
        };
      };
    };
  };
}
