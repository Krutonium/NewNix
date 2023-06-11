{ config, pkgs, lib, ... }:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uWebServer";
  Internet_In = "enp4s0";
in
{
  system.autoUpgrade.allowReboot = true;
  networking.firewall.allowedTCPPorts = [ 25565 25566 50056 ];
  networking.firewall.allowedUDPPorts = [ 50056 67 68 ];
  boot = {
    kernelPackages = kernel;
  };
  zramSwap = {
    enable = true;
    priority = 1;
  };
  imports = [ ./uWebServer-hw.nix ./uWebServer-networking.nix ];
  #services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  sys = {
    boot = {
      bootloader = "uefi";
      plymouth_enabled = false;
    };
    desktop = {
      desktop = "none";
      wayland = false;
    };
    audio = {
      server = "none";
    };
    users = {
      krutonium = true;
      home-manager = false;
      root = true;
      kea = true;
    };
    services = {
      plex = true;
      avahi = true;
      coredns = false;
      samba = true;
      satisfactoryServer = false;
      ssh = true;
      sshGuard = true;
      synapse = true;
      gitea = true;
      torrent = true;
      ddns = false;
      nginx = true;
      autoDeploy = false;
      sevendaystodie = false;
      headscale = false;
      tailscale = false;
      tailscaleUseExitNode = false;
      homeAssistant = true;
    };
    virtualization = {
      server = "virtd";
    };
    minecraft = {
      rubberdragontrain = true;
    };
  };
  services.cron.systemCronJobs = [
    "0 6 * * * root systemctl reboot"
  ];
}
