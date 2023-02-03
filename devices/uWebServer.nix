{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_latest;
  Hostname = "uWebServer";
in
{
  networking.firewall.allowedTCPPorts = [ 25565 ];
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  networking.interfaces."enp3s0".ipv6.addresses = [{ address = "2607:fea8:7a5f:2a00::916c"; prefixLength = 64; }];
  networking.interfaces."enp3s0".ipv4.addresses = [{ address = "192.168.0.10"; prefixLength = 24; }];
  networking.defaultGateway = { address = "192.168.0.1"; interface = "enp3s0"; };
  networking.defaultGateway6 = { address = "fe80::1"; interface = "enp3s0"; };
  imports = [ ./uWebServer-hw.nix ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
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
      coredns = true;
      samba = true;
      satisfactoryServer = false;
      ssh = true;
      sshGuard = false;
      synapse = true;
      gitea = true;
      torrent = true;
      ddns = false;
      nginx = true;
      autoDeploy = true;
    };
    virtualization = {
      server = "virtd";
    };
    minecraft = {
      rubberdragontrain = true;
    };
  };
}
