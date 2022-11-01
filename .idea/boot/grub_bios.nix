{ config, pkgs, ... }:
let
  installTarget = "/dev/sda";
  devices = [ "nodev" ];
  default = "saved";
in
{
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
}
