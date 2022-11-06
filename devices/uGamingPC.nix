{ config, pkgs, ...}:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uGamingPC";
in
{
  boot.kernelPackages = kernel;
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
    users = {
      krutonium = true;
      home-manager = true;
    };
  };
}