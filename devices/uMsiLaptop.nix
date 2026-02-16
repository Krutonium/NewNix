{ config, pkgs, ... }:
let
  #kernel = pkgs.nvidiaFor "580.119.02" pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  kernel = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  video = config.boot.kernelPackages.nvidiaPackages.stable;
  Hostname = "uMsiLaptop";
in
{
  systemd.targets.sleep.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  boot.extraModprobeConfig = ''
    options iwlwifi bt_coex_active=0
  '';
  boot.initrd.systemd.enable = true;
  boot.kernelPackages = kernel;
  boot.kernelModules = [ "ec_sys" ];
  networking.hostName = Hostname;
  networking.networkmanager.wifi.powersave = false;
  networking.firewall.interfaces."enp3s0".allowedUDPPorts = [ 67 ];
  boot.kernelParams = [
    "nouveau.config=NvClkMode=15"
    "mitigations=off"
    "i915.enable_psr=0"
    "i915.enable_rc6=0"
  ];
  boot.loader.grub.gfxmodeEfi = "1920x1080";
  boot.loader.grub.gfxpayloadEfi = "keep";
  systemd.network.enable = true;
  environment.systemPackages = [
    pkgs.perf
    pkgs.teamviewer
  ];
  environment.sessionVariables = {
    #__EGL_VENDOR_LIBRARY_FILENAMES = "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json";
  };
  imports = [
    ./uMsiLaptop-hw.nix
    ../builders
  ];
  nix = {
    settings = {
      max-jobs = 4;
    };
  };
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/34d142d4-9274-4901-a938-2f8bcc8c8ed6";
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
      nbfc = false;
      syncthing = false;
    };
    virtualization = {
      server = "virtd";
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
  };
  virtualisation.waydroid.enable = false;
  systemd.network.wait-online.enable = false;
  # This theoretically fixes the speakers being slept constantly.
  services.pipewire.wireplumber.extraConfig."99-disable-audio-sleep" = {
    "monitor.alsa.rules" = [
      {
        matches = "alsa_output.pci-0000_00_1b.0.analog-stereo";
      }
    ];
    actions = {
      update-props = {
        "session.suspend-timeout-seconds" = 0;
      };
    };
  };
  services.flatpak.enable = true;
  hardware = {
    graphics.enable = true;
    #Disabled due to Charger being too low wattage.
    nvidia = {
      open = false; # NV110 - Not Open Supported
      package = video;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];
  services.teamviewer.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
}
