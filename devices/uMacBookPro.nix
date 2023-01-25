{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_5_4;
  Hostname = "uMacBookPro";
in
{
  networking.hostName = Hostname;
  hardware.opengl.enable = true;
  hardware.enableAllFirmware = true;
  boot.kernelPackages = kernel;
  #boot.initrd.availableKernelModules = [ "nouveau" ]; #Fix not grabbing the display before login manager
  boot.kernelModules = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.allowBroken = true;

  imports = [ ./uMacBookPro-hw.nix ];
  sys = {
    boot = {
      bootloader = "uefi";
      plymouth_enabled = true;
      uefiPath = "/boot/efi";
    };
    desktop = {
      desktop = "gnome";
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
    # "nouveau.config=NvBios=${../firmware/8600M_GT.rom}"
    "nouveau.config=NvGrUseFw=1"
  ];
  powerManagement.cpuFreqGovernor = "performance";
}
