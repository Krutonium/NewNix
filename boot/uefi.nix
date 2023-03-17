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
    environment.boot = {
      netbootxyz.efi.source = ${pkgs.netbootxyz-efi} };
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
            extraEntries = ''
              title iPXE
                chainloader 
            '';
          };
        };
      };
    };
  }
