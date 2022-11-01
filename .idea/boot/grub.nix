{ config, pkgs, ... }:
let
  mountPoint = "/boot";
  devices = "nodev";
  default = "saved";
in
{
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
}
