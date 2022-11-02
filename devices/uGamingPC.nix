{ config, pkgs, ...}:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uGamingPC";
in
{
  boot.kernelPackages = kernel;
  sys.boot.bootloader = "uefi";
  sys.desktop = "gnome";
}