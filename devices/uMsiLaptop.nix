{ config, pkgs, ...}:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uMsiLaptop";
in
{
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  imports =  [ ./uMsiLaptop-hw.nix ];
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
      root = true;
    };
    services = {
      avahi = true;
      ssh = true;
      sshGuard = true;
    };
  };
}