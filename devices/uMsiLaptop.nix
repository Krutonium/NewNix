{ config, pkgs, ... }:
let
  kernel = pkgs.unstable.linuxPackages_zen;
  video = config.boot.kernelPackages.nvidiaPackages.stable;
  Hostname = "uMsiLaptop";
in
{
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
  environment.systemPackages = [
    kernel.perf
    pkgs.teamviewer
  ];
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
    steam = {
      steam = false;
    };
    virtualization = {
      server = "none";
    };
  };
  virtualisation.waydroid.enable = false;
  programs.steam = {
    enable = false;
  };
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
  hardware = {
    graphics.enable = true;
    #Disabled due to Charger being too low wattage.
    nvidia = {
      open = false;
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
  services.xserver.videoDrivers = [ "modesetting" ];
  services.teamviewer.enable = true;
  services.upower.enable = true;
  services.tlp.enable = true;
}
