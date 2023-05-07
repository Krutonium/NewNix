{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_zen;
  video = config.boot.kernelPackages.nvidiaPackages.stable;
  Hostname = "uGamingPC";
in
{
  boot.kernelPackages = kernel;
  boot.loader.grub.gfxmodeEfi = "1920x1080";
  boot.loader.grub.gfxpayloadEfi = "keep";
  networking.hostName = Hostname;
  networking.firewall.allowedTCPPorts = [ 1337 ];
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
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.unstable.openrgb;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.open = false;
  hardware.opengl.enable = true;
  hardware.nvidia.package = video;
  boot.initrd.availableKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  environment.systemPackages = [
    video
  ];
  programs.wireshark.enable = true;
  hardware.nvidia.modesetting.enable = true;
  sys = {
    boot = {
      bootloader = "uefi";
      uefiPath = "/boot/efi";
      plymouth_enabled = true;
    };
    desktop = {
      desktop = "gnome";
      wayland = false;
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
      tailscale = false;
      tailscaleUseExitNode = false;
    };
    steam = {
      steam = true;
    };
    virtualization = {
      server = "virtd";
    };
  };
}
