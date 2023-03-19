{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages;
  Hostname = "uWebServer";
in
{
  networking.firewall.allowedTCPPorts = [ 25565 25566 ];
  boot.kernelPackages = kernel;

  networking = {
    hostName = Hostname;
    networkmanager.insertNameservers = [ "2607:fea8:7a5f:2a00::4c18" ];
    interfaces = {
      "enp0s3" = {
        ipv4.addresses = [{ address = "192.168.0.10"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "2607:fea8:7a5f:2a00::4c18"; prefixLength = 64; }];
      };
    };
    defaultGateway = { address = "192.168.0.1"; interface = "enp3s0"; };
    defaultGateway6 = { address = "fe80::1"; interface = "enp3s0"; };
    tempAddresses = "disabled";
  };

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
      sevendaystodie = false;
    };
    virtualization = {
      server = "virtd";
    };
    minecraft = {
      rubberdragontrain = true;
    };
  };
}
