{ config, pkgs, ...}:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uGamingPC";
in
{
  boot.kernelPackages = kernel;
  imports = [
    ../boot
    ../audio
    ../desktop
  ];
  sys = {
    boot = {
      bootloader = "uefi";
    };
    desktop = {
      desktop = "gnome";
      wayland = true;
    };
    audio = {
      server = "pipewire";
    };
  };
}