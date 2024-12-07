{ config, pkgs, ... }:
let
  kernel = with pkgs; unstable.linuxPackages_zen;
  video = config.boot.kernelPackages.nvidiaPackages.beta;
  zenpower = config.boot.kernelPackages.zenpower;
  Hostname = "uGamingPC";
in
{
  #hardware.firmware = [ video.firmware ];
  boot = {
    kernelPackages = kernel;
    kernelParams = [ "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1" "nvidia.NVreg_EnableResizableBar=1" "mitigations=off" ];
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
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    webkitgtk_4_1
  ];
  # Disable Sleep/Hibernate System Wide
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  

  services.flatpak.enable = true;
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
    enable = false;
  };
  virtualisation.spiceUSBRedirection.enable = true;
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 krutonium qemu-libvirtd -"
  ];

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    autoStart = true;
    config = {
      enable = true;
      json = {
        scale = 1.0; # No Foviation
        bitrate = 250000000; #250Mbit
        encoders = [{
          encoder = "vaapi";
          codec = "h265";
          width = 1.0;
          height = 1.0;
          offset_x = 0.0;
          offset_y = 0.0;
        }];
      };
    };
  };

  networking = {
    hostName = Hostname;
    firewall = {
      allowedTCPPorts = [ 47984 47989 48010 1337 11434 ]; #11434 is Ollama
      allowedUDPPorts = [ 47998 47999 48000 48010 ];
      allowedTCPPortRanges = [{ from = 9943; to = 9944; }]; #ALVR
      allowedUDPPortRanges = [{ from = 9943; to = 9944; }];
    };
  };
  services.teamviewer.enable = true;

  imports = [
    ./uGamingPC-hw.nix
  ];
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
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
  # Allow Ollama through Firewall
  
  hardware.nvidia = {
    powerManagement = {
      enable = true;
    };
    package = video;
    prime.offload.enable = false;
    open = false;
    nvidiaSettings = false;
    modesetting.enable = true;
  };
  hardware.keyboard.qmk.enable = true;

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    #deviceSection = ''
    #  Driver                 "nvidia"
    #  VendorName             "NVIDIA Corporation"
    #  BoardName              "NVIDIA GeForce RTX 3070"
    #  Option                 "Coolbits" "8"
    #'';
    #screenSection = ''
    #  Option "metamodes" "DP-4: 1920x1080_165 +1920+0 {AllowGSYNCCompatible=On}, DP-0: 1920x1080_165 +0+0 {AllowGSYNCCompatible=On}, DP-2: 1920x1080_165 +3840+0 {AllowGSYNCCompatible=On}"
    #'';
    #logFile = "/var/log/xorg.log";
    #displayManager.setupCommands = ''
    #  xrandr --output HDMI-0 --mode 1920x1080 --pos 3840x0 --rotate normal --output DP-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-2 --mode 1920x1080 --pos 0x0 --rotate normal
    #'';
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  boot.extraModulePackages = with config.boot.kernelPackages;
    [
      zenpower.out
      pkgs.ddcutil.out
    ];
  boot.blacklistedKernelModules = [ "k10temp" "amdgpu" ];
  environment.systemPackages = [
    #video
    pkgs.gamescope
    pkgs.piper
    pkgs.unstable.alvr
    pkgs.sunshine
  ];
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };

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
      alvr = false;
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
