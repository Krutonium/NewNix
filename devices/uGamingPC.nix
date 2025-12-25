{ config
, pkgs
, lib
, ...
}:
let
  kernel = pkgs.linuxPackages_zen;
  video = config.boot.kernelPackages.nvidiaPackages.latest;
  zenpower = config.boot.kernelPackages.zenpower;
  ddcci = config.boot.kernelPackages.ddcci-driver;
  Hostname = "uGamingPC";
  kernelModules = [
    "dm-mod"
    "dm-cache"
    "dm-cache-mq"
    "dm-persistent-data"
    "ddcci"
    "i2c-dev" #RGB
    "i2c-piix4"
  ];
in
{
  #hardware.firmware = [ video.firmware ];
  boot = {
    kernelPackages = kernel;
    kernelParams = [
      "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1"
      "nvidia.NVreg_EnableResizableBar=1"
      "mitigations=off"
      "acpi_enforce_resources=lax"
    ];
    tmp.useTmpfs = false;
    loader.grub = {
      gfxmodeEfi = "1920x1080";
      gfxpayloadEfi = "keep";
    };
    supportedFilesystems = [ "ntfs" ];
  };
  services.udev.packages = [
    pkgs.qmk-udev-rules
    pkgs.logitech-udev-rules
    pkgs.via
  ];
  programs.ydotool.enable = true;
  programs.ydotool.group = "krutonium";
  programs.gamemode.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    ocl-icd
  ];
  # Disable Sleep/Hibernate System Wide
  systemd.targets.sleep.enable = true;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.flatpak.enable = true;
  services.ratbagd.enable = true;
  systemd.services."mount-games" = {
    # This is a HACK because the default mounter just utterly dies with bcachefs.
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "root";
    path = with pkgs; [
      pkgs.bcachefs-tools
      pkgs.util-linux
    ];
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
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Type = "simple";
      # Run as root since we need direct hardware access
      User = "root";
      Group = "root";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
  systemd.services.set-gpu-power-limit = {
    description = "Set NVIDIA GPU Power Limit";
    wantedBy = [ "multi-user.target" ]; # ensures it runs at boot
    after = [ "default.target" ];
    path = [ ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -i 0 -pl 300";
      RemainAfterExit = true;
      User = "root";
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 krutonium qemu-libvirtd -"
  ];
  networking = {
    hostName = Hostname;
    firewall = {
      allowedTCPPorts = [
        47984
        47989
        48010
        1337
        11434
      ]; # 11434 is Ollama
      allowedUDPPorts = [
        47998
        47999
        48000
        48010
      ];
      allowedTCPPortRanges = [
        {
          from = 9943;
          to = 9944;
        }
      ]; # ALVR
      allowedUDPPortRanges = [
        {
          from = 9943;
          to = 9944;
        }
      ];
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
    package = pkgs.openrgb-with-all-plugins;
  };
  services.ollama = {
    enable = false;
    # acceleration = "cuda";
  };
  # Allow Ollama through Firewall

  hardware.nvidia = {
    powerManagement = {
      enable = true;
    };
    package = video;
    prime.offload.enable = false;
    open = true;
    nvidiaSettings = true;
    modesetting.enable = true;
  };
  nixpkgs.config.cudaSupport = false;
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
    extraPackages = [ pkgs.monado-vulkan-layers ];
  };
  boot.extraModulePackages = with config.boot.kernelPackages; [
    zenpower.out
    pkgs.ddcutil.out
    ddcci
  ];
  boot.blacklistedKernelModules = [
    "k10temp"
    "amdgpu"
    "i2c-piix4"
  ];

  boot.kernelModules = kernelModules;
  boot.initrd.kernelModules = kernelModules;
  environment.systemPackages = [
    #video
    pkgs.gamescope
    pkgs.piper
    # Normally I wouldn't but I need this on this PC and not my laptop. TODO: Address in eventual re-write
    pkgs.davinci-resolve
    #pkgs.monado-vulkan-layers
    #pkgs.wlx-overlay-s
    #pkgs.lact
    pkgs.wlx-overlay-s
    pkgs.xrizer
    pkgs.wayvr-dashboard
  ];
  programs = {
    wireshark.enable = true;
    adb.enable = true;
    tuxclocker = { 
      enable = true;
      useUnfree = true;
      enabledNVIDIADevices = [ 0 1 ];
    };
  };
  #Fix Discord and other Chromium based Bullshit
  #environment.sessionVariables.NIXOS_OZONE_WL = "1";
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
      ddcutil = false;
      ddcutil_nvidiaFix = false;
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
    virtualization = {
      server = "virtd";
      windows = true;
    };
  };
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      steamtinkerlaunch
    ];
    protontricks.enable = true;
  };
  services.wivrn = {
    # https://github.com/WiVRn/WiVRn-APK/releases
    enable = true;
    openFirewall = true;
    package = (pkgs.unstable.wivrn.override { cudaSupport = true; });
    # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
    # will automatically read this and work with WiVRn (Note: This does not currently
    # apply for games run in Valve's Proton)
    defaultRuntime = true;

    # Run WiVRn as a systemd service on startup
    autoStart = true;

    # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
    config = {
      enable = true;
      json = {
        # 1.0x foveation scaling
        scale = 1.0;
        # 300 Mb/s
        bitrate = 300000000;
        encoders = [
          {
            encoder = "vaapi";
            codec = "h265";
            # 1.0 x 1.0 scaling
            width = 1.0;
            height = 1.0;
            offset_x = 0.0;
            offset_y = 0.0;
          }
        ];
      };
    };
  };
}
