{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_latest;
  Hostname = "uMacBookPro";
in
{
  networking.hostName = Hostname;
  hardware.opengl.enable = true;
  hardware.enableAllFirmware = true;
  boot.kernelPackages = kernel;
  boot.initrd.availableKernelModules = [ "nouveau" ]; #Fix not grabbing the display before login manager
  imports = [ ./uMacBookPro-hw.nix ];
  sys = {
    boot = {
      bootloader = "uefi";
      plymouth_enabled = true;
    };
    desktop = {
      desktop = "pantheon";
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
    };
    steam = {
      steam = true;
    };
  };
}
