{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages;
  Hostname = "uWebServer";
  Internet_In = "enp4s0";
in
{
  networking.firewall.allowedTCPPorts = [ 25565 25566 50056 ];
  networking.firewall.allowedUDPPorts = [ 50056 ];
  boot.kernelPackages = kernel;

  networking = {
    hostName = Hostname;
    networkmanager.insertNameservers = [ "2607:fea8:7a5f:2a00::9b46" ];
    interfaces = {
      Internet_In = {
        ipv4.addresses = [{ address = "192.168.0.10"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "2607:fea8:7a5f:2a00::9b46"; prefixLength = 128; }];
      };
    };
    defaultGateway = { address = "192.168.0.1"; interface = Internet_In; };
    defaultGateway6 = { address = "fe80::1"; interface = Internet_In; };
    tempAddresses = "disabled";
  };
  services.create_ap = {
    enable = true;
    settings = {
      INTERNET_IFACE = Internet_In;
      WIFI_IFACE = "wlp12s0";
      SSID = "TestNetwork";
      PASSPHRASE = "12345678";
    };
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
      headscale = false;
      tailscale = false;
      tailscaleUseExitNode = false;
    };
    virtualization = {
      server = "virtd";
    };
    minecraft = {
      rubberdragontrain = true;
    };
  };
}
