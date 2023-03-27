{ config, pkgs, lib, ... }:
let
  kernel = pkgs.unstable.linuxPackages_zen;
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
  boot.initrd.availableKernelModules = [ "nouveau" ];
  networking.hostName = Hostname;
  boot.loader.grub.gfxmodeEfi = "1920x1080";
  boot.loader.grub.gfxpayloadEfi = "keep";
  boot.kernelParams = [
    "nouveau.config=NvBios=${../firmware/GTX_950M_OC.rom}"
  ];

  imports = [ ./uMsiLaptop-hw.nix ];
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
      #noisetorch = true;
      #noisetorchDevice = "alsa_input.pci-0000_00_1b.0.analog-stereo";
      tailscale = true;
    };
    steam = {
      steam = true;
    };
    virtualization = {
      server = "virtd";
    };
  };
  boot.kernelModules = [ "mem_sleep_default=deep" ];
  specialisation."nVidia".configuration = {
    system.nixos.tags = [ "with-nvidia" ];
    system.nixos.label = "nVidia";
    sys.desktop.wayland = lib.mkForce false;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.opengl.enable = true;
    environment.systemPackages = [ nvidia-offload ];
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      open = true;
      powerManagement.enable = true;
      prime = {
        offload.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };
}
