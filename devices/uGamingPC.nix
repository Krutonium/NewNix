{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_zen;
  video = config.boot.kernelPackages.nvidiaPackages.beta;
  Hostname = "uGamingPC";
in
{
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  imports = [ ./uGamingPC-hw.nix ];
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
  services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.open = false;
  hardware.opengl.enable = true;
  hardware.nvidia.package = video;
  boot.initrd.availableKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  environment.systemPackages = [
    video
  ];
  hardware.nvidia.modesetting.enable = true;
  sys = {
    boot = {
      bootloader = "uefi";
      plymouth_enabled = true;
    };
    desktop = {
      desktop = "gnome";
      wayland = true;
    };
    custom = {
      ddcutil = true;
      ddcutil_nvidiaFix = true;
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
    steam = {
      steam = true;
    };
    virtualization = {
      server = "virtd";
    };
  };
}
