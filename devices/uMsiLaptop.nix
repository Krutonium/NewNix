{ config, pkgs, lib, ... }:
let
  kernel = pkgs.unstable.linuxPackages_latest;
  video = config.boot.kernelPackages.nvidiaPackages.beta;
  Hostname = "uMsiLaptop";
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  boot.initrd.systemd.enable = false;
  boot.kernelPackages = kernel;
  #boot.initrd.availableKernelModules = [ "nvidia" ];
  networking.hostName = Hostname;
  networking.firewall.interfaces."enp3s0".allowedUDPPorts = [ 67 ];
  #boot.kernelParams = [ "nouveau.config=NvClkMode=15" ];
  boot.loader.grub.gfxmodeEfi = "1920x1080";
  boot.loader.grub.gfxpayloadEfi = "keep";
  environment.systemPackages = [ 
    kernel.perf 
    pkgs.teamviewer 
    nvidia-offload 
    #pkgs.waybar
  ];
  imports = [ ./uMsiLaptop-hw.nix ];
  nix = {
    settings = {
      max-jobs = 0;
    };
  };
  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/swap";
      priority = 1;
    }
  ];
  zramSwap = {
    enable = true;
    priority = 5;
    #writebackDevice = "/dev/disk/by-uuid/34d142d4-9274-4901-a938-2f8bcc8c8ed6";
    memoryPercent = 25;
  };
  sys = {
    boot = {
      bootloader = "uefi";
      plymouth_enabled = true;
    };
    desktop = {
      desktop = "gnome";
      wayland = true;
      displayManager = "gdm";
    };
    audio = {
      server = "pipewire";
    };
    users = {
      krutonium = true;
      root = true;
    };
    roles = {
      desktop = true;
    };
    services = {
      avahi = true;
      ssh = true;
      sshGuard = true;
      #noisetorch = true;
      #noisetorchDevice = "alsa_input.pci-0000_00_1b.0.analog-stereo";
      tailscale = false;
      tailscaleUseExitNode = false;
      nbfc = false;
      syncthing = false;
    };
    steam = {
      steam = false;
    };
    virtualization = {
      server = "none";
    };
  };
  virtualisation.waydroid.enable = false;
  programs.steam = {
    enable = true;
  };
  #services.teamviewer.enable = true;
  #boot.kernelModules = [ "mem_sleep_default=deep" ];
  #specialisation."bumblebee".configuration = {
  #  system.nixos.tags = [ "with-bumblebee" ];
  #  system.nixos.label = "bumblebee";
  #  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  #  hardware.bumblebee = {
  #    enable = true;
  #    driver = "nvidia";
  #    pmMethod = "bbswitch";
  #  };
  #  boot.blacklistedKernelModules = [ "nouveau" ];
  #};
  specialisation."nVidia".configuration = {
    boot.initrd.availableKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
    #boot.blacklistedKernelModules = [ "nouveau" ];
    system.nixos.tags = [ "with-nvidia" ];
    system.nixos.label = "nVidia";
    # sys.desktop.wayland = lib.mkForce false;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.opengl.enable = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    hardware.nvidia = {
      package = video;
      modesetting.enable = true;
      nvidiaSettings = true;
      open = false;
      powerManagement.finegrained = true;
      prime = {
        offload.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };
}
