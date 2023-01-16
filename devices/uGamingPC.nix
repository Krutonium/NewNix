{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_latest;
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
  hardware.nvidia.open = true;
  hardware.opengl.enable = true;
  hardware.nvidia.package = video;
  boot.initrd.availableKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  #boot.kernelParams = [ "iommu=soft" "udev.event-timeout=1" ]; #VL805 USB Card
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
      wayland = false;
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
