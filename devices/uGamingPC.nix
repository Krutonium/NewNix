{ config, pkgs, ... }:
let
  kernel = with pkgs; master.linuxPackages_zen;
  video = config.boot.kernelPackages.nvidia_x11_vulkan_beta;
  # Starfield
  #kernel = with pkgs; linuxPackages_zen;
  #video = config.boot.kernelPackages.nvidia_x11_vulkan_beta;
  zenpower = config.boot.kernelPackages.zenpower;
  Hostname = "uGamingPC";
in
{
  boot = {
    kernelPackages = kernel;
    tmp.useTmpfs = true;
    loader.grub = {
      gfxmodeEfi = "1920x1080";
      gfxpayloadEfi = "keep";
    };
  };
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
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    deviceSection = ''
        Driver                 "nvidia"
        VendorName             "NVIDIA Corporation"
        BoardName              "NVIDIA GeForce RTX 3070"
        Option                 "AllowHMD" "yes"
        Option                 "ModeValidation" "AllowNonEdidModes"
      '';
    logFile = null;
    displayManager.setupCommands = ''
      xrandr --output HDMI-0 --mode 1920x1080 --pos 3840x0 --rotate normal --output DP-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-2 --mode 1920x1080 --pos 0x0 --rotate normal
    '';
    };
  hardware.opengl.enable = true;
  hardware.nvidia.package = video;
  boot.initrd.availableKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ zenpower.out ];
  boot.blacklistedKernelModules = [ "k10temp" ];
  environment.systemPackages = [
    video
  ];
  programs.wireshark.enable = true;
  hardware.nvidia.modesetting.enable = true;
  #Fix Discord and other Chromium based Bullshit
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  sys = {
    boot = {
      bootloader = "uefi";
      uefiPath = "/boot/efi";
      plymouth_enabled = true;
    };
    desktop = {
      desktop = "kde";
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
      steam = false; #HTTP Error with Monado, Enable Later 
    };
    virtualization = {
      server = "virtd";
    };
  };
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  # Temporary Patch
}
