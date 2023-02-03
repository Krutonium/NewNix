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
  boot.initrd.kernelModules = [ "nouveau" "msr" ];
  boot.kernelModules = [ "msr" ];
  boot.loader.grub.gfxmodeBios = "1680x1050";
  boot.loader.grub.gfxpayloadBios = "keep";
  imports = [ ./uMacBookPro-hw.nix ];
  sys = {
    boot = {
      bootloader = "bios";
      plymouth_enabled = true;
      uefiPath = "/boot/";
    };
    desktop = {
      desktop = "kde";
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
    #"nouveau.config=NvBios=${../firmware/8600M_GT.rom}"
    #"debug=VBIOS=debug"
    #"nomodeset"
  ];
  powerManagement.cpuFreqGovernor = "performance";
  environment.systemPackages = [ pkgs.msr pkgs.msr-tools ];
}
