{ config, pkgs, ... }:
let
  kernel = with pkgs; unstable.linuxPackages_latest;
  video = config.boot.kernelPackages.nvidia_x11;
  zenpower = config.boot.kernelPackages.zenpower;
  Hostname = "uGamingPC";
in
{
  boot = {
    kernelPackages = kernel;
    kernelParams = [ "amd_iommu=on" "iommu=pt" ];
    tmp.useTmpfs = false;
    loader.grub = {
      gfxmodeEfi = "1920x1080";
      gfxpayloadEfi = "keep";
    };
  };

  networking = { 
    hostName = Hostname;
    firewall = {
      allowedTCPPorts = [ 47984 47989 48010 1337 ];
      allowedUDPPorts = [ 47998 47999 48000 48010 ];
      allowedTCPPortRanges = [ { from = 9943; to = 9944; } ]; #ALVR
      allowedUDPPortRanges = [ { from = 9943; to = 9944; } ];
    };
    bridges = {
      "bridge" = {
        interfaces = [ "eno1" ];
      };
    };
    nat = {
      enable = true;
      externalInterface = "eno1";
      internalInterfaces = [ "bridge" ];
    };
  };
  imports = [ ./uGamingPC-hw.nix ];
  #swapDevices = [
  #  {
  #    device = "/swap";
  #    size = 8192;
  #    priority = 0;
  #  }
  #];
  zramSwap = {
    enable = true;
    priority = 1;
  };
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb;
  };
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    deviceSection = ''
      Driver                 "nvidia"
      VendorName             "NVIDIA Corporation"
      BoardName              "NVIDIA GeForce RTX 3070"
      Option                 "AllowHMD" "yes"
      Option                 "ModeValidation" "AllowNonEdidModes,NoEdidMaxPClkCheck,NoMaxPClkCheck"
    '';
    screenSection = ''
      Option                 "metamodes" "nvidia-auto-select +0+0 { AllowGSYNCCompatible=On }"
    '';
    logFile = "/var/log/xorg.log";
    #displayManager.setupCommands = ''
    #  xrandr --output HDMI-0 --mode 1920x1080 --pos 3840x0 --rotate normal --output DP-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-2 --mode 1920x1080 --pos 0x0 --rotate normal
    #'';
  };
  hardware.opengl.enable = true;
  hardware.nvidia.package = video;
  boot.initrd.availableKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ zenpower.out ];
  boot.blacklistedKernelModules = [ "k10temp" ];
  environment.systemPackages = [
    video
    pkgs.gamescope
  ];
  programs.wireshark.enable = true;
  hardware.nvidia.modesetting.enable = true;
  #Fix Discord and other Chromium based Bullshit
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  sys = {
    boot = {
      bootloader = "uefi";
      uefiPath = "/boot";
      plymouth_enabled = true;
    };
    desktop = {
      displayManager = "lightdm";
      desktop = "gnome";
      wayland = true;
    };
    custom = {
      ddcutil = true;
      ddcutil_nvidiaFix = true;
      alvr = true;
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
      steam = true; #HTTP Error with Monado, Enable Later 
    };
    virtualization = {
      server = "virtd";
    };
  };
  #programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  # Temporary Patch
}
