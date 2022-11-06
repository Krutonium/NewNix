{ config, pkgs, ...}:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uHPLaptop";
in
{
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  imports =  [ ./uHPLaptop-hw.nix ];
  sys = {
    boot = {
      bootloader = "bios";
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
      root = true;
    };
  };
}