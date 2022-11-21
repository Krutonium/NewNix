{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uMsiLaptop";
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  imports = [ ./uMsiLaptop-hw.nix ];
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
  boot.kernelModules = [ "mem_sleep_default=deep" ];
  specialisation."nVidia".configuration = {
    system.nixos.tags = [ "with-nvidia" ];
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.opengl.enable = true;
    environment.systemPackages = [ nvidia-offload ];
    services.xserver.videoDrivers = [ "modesetting" ];
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powermanagement.enable = true;
      prime = {
        offload.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };
}
