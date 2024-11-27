{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uHPLaptop";
in
{
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  boot.kernelParams = [ "acpi_backlight=native" "mitigations=off" ];
  imports = [ ./uHPLaptop-hw.nix ];
  swapDevices = [
    {
      device = "/swap";
      size = 8192;
      priority = 0;
    }
  ];
  zramSwap = {
    enable = true;
    priority = 1;
  };
  sys = {
    boot = {
      bootloader = "bios";
      plymouth_enabled = true;
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
      sshGuard = false;
    };
    steam = {
      steam = true;
    };
    virtualization = {
      server = "virtd";
    };

  };
}
