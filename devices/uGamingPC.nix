{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uGamingPC";
in
{
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  imports = [ ./uGamingPC-hw.nix ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  boot.initrd.availableKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  sys = {
    boot = {
      bootloader = "uefi";
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
      sshGuard = true;
    };
    steam = {
      steam = true;
    };
  };
}
