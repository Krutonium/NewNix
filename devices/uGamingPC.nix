{ config, pkgs, ... }:
let
  kernel = with pkgs; unstable.linuxPackages_latest;
  video = config.boot.kernelPackages.nvidiaPackages.beta;
  zenpower = config.boot.kernelPackages.zenpower;
  #ddcutil = config.boot.kernelPackages.ddcci-driver;
  ddcutil = config.boot.kernelPackages.ddcci-driver.overrideAttrs (old: {
    patches = [
      (pkgs.fetchpatch {
        url = "https://gitlab.com/Sweenu/ddcci-driver-linux/-/commit/7f851f5fb8fbcd7b3a93aaedff90b27124e17a7e.patch";
        hash = "sha256-Y1ktYaJTd9DtT/mwDqtjt/YasW9cVm0wI43wsQhl7Bg=";
      })
    ];
  });
  Hostname = "uGamingPC";
in
{
  boot = {
    kernelPackages = kernel;
    kernelParams = [ "amd_iommu=on" "iommu=pt" "vfio-pci.ids=1002:731f,1002:ab38" ];
    tmp.useTmpfs = false;
    loader.grub = {
      gfxmodeEfi = "1920x1080";
      gfxpayloadEfi = "keep";
    };
    supportedFilesystems = [ "bcachefs" ];
  };
  services.udev.packages = [
    pkgs.qmk-udev-rules
    pkgs.logitech-udev-rules
    pkgs.via
  ];
  services.ratbagd.enable = true;
  systemd.services."mount-games" = {
    # This is a HACK because the default mounter just utterly dies with bcachefs.
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "root";
    path = with pkgs; [ pkgs.bcachefs-tools pkgs.util-linux ];
    script = ''
      if mountpoint -q /games; then
        echo "games already mounted"
      else
         mkdir -p /games
         bcachefs mount UUID=3bf2876e-bdcc-45da-ac94-a5bcbf996df8 /games
      fi
    '';
    wantedBy = [ "multi-user.target" ];
    enable = true;
  };
  virtualisation.spiceUSBRedirection.enable = true;
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 krutonium qemu-libvirtd -"
  ];
  networking = {
    hostName = Hostname;
    firewall = {
      allowedTCPPorts = [ 47984 47989 48010 1337 ];
      allowedUDPPorts = [ 47998 47999 48000 48010 ];
      allowedTCPPortRanges = [{ from = 9943; to = 9944; }]; #ALVR
      allowedUDPPortRanges = [{ from = 9943; to = 9944; }];
    };
  };
  services.teamviewer.enable = true;

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
  hardware.keyboard.qmk.enable = true;
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    #deviceSection = ''
    #  Driver                 "nvidia"
    #  VendorName             "NVIDIA Corporation"
    #  BoardName              "NVIDIA GeForce RTX 3070"
    #  Option                 "AllowHMD" "yes"
    #  Option                 "ModeValidation" "AllowNonEdidModes,NoEdidMaxPClkCheck,NoMaxPClkCheck"
    #'';
    screenSection = ''
      Option "metamodes" "DP-4: 1920x1080_165 +1920+0 {AllowGSYNCCompatible=On}, DP-0: 1920x1080_165 +0+0 {AllowGSYNCCompatible=On}, DP-2: 1920x1080_165 +3840+0 {AllowGSYNCCompatible=On}"
    '';
    #logFile = "/var/log/xorg.log";
    #displayManager.setupCommands = ''
    #  xrandr --output HDMI-0 --mode 1920x1080 --pos 3840x0 --rotate normal --output DP-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-2 --mode 1920x1080 --pos 0x0 --rotate normal
    #'';
  };
  hardware.opengl.enable = true;
  hardware.nvidia = {
    package = video;
    open = false; #some day my beauty
    nvidiaSettings = true;
  };
  boot.initrd.availableKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = with config.boot.kernelPackages;
    [
      zenpower.out
      ddcutil.out
    ];
  boot.blacklistedKernelModules = [ "k10temp" "amdgpu" ];
  environment.systemPackages = [
    video
    pkgs.gamescope
    pkgs.piper
  ];
  programs = {
    wireshark.enable = true;
    adb.enable = true;
  };
  #Fix Discord and other Chromium based Bullshit
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  sys = {
    boot = {
      bootloader = "uefi";
      uefiPath = "/boot";
      plymouth_enabled = true;
    };
    desktop = {
      displayManager = "gdm";
      desktop = "gnome";
      wayland = true;
    };
    custom = {
      ddcutil = true;
      ddcutil_nvidiaFix = true;
      alvr = true;
    };
    audio = {
      server = "pulseaudio";
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
      tailscale = false;
      tailscaleUseExitNode = false;
    };
    steam = {
      steam = true; #HTTP Error with Monado, Enable Later 
    };
    virtualization = {
      server = "virtd";
      windows = true;
    };
  };
  #programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  # Temporary Patch
}
