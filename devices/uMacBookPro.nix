{ config, pkgs, ... }:
let
  #kernel = pkgs.linuxPackages_5_4;
  kernel = pkgs.linuxPackages_latest;
  #kernel = pkgs.linuxPackages_4_14;
  Hostname = "uMacBookPro";
in
{
  networking.hostName = Hostname;
  hardware.opengl.enable = true;
  hardware.enableAllFirmware = true;
  boot.kernelPackages = kernel;
  #boot.initrd.availableKernelModules = [ "nouveau" ]; #Fix not grabbing the display before login manager
  #boot.kernelModules = [ "nvidia" ];
  #hardware.nvidia = {
  #  package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
  #};
  #services.xserver.videoDrivers = [ "nvidia" ];
  #boot.kernelModules = [ "nouveau" ];
  #nixpkgs.config.allowBroken = true;

  imports = [ ./uMacBookPro-hw.nix ];
  sys = {
    boot = {
      bootloader = "bios";
      plymouth_enabled = true;
      uefiPath = "/boot/efi";
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

  #Hardware Specific Quirks:
  services.mbpfan = {
    enable = true;
    settings.general = {
      low_temp = 30;
      high_temp = 45;
      max_temp = 60;
    };
  };
  boot.kernelParams = [
    #"nouveau.config=NvBios=PCIROM"
    "nomodeset"
  ];
  powerManagement.cpuFreqGovernor = "performance";
}
