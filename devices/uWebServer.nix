{ config, pkgs, ...}:
let
  kernel = pkgs.linuxPackages;
  Hostname = "uWebServer";
in
{
  networking.firewall.allowedTCPPorts = [ 25565 ];
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  imports =  [ ./uWebServer-hw.nix ];
  sys = {
    boot = {
      bootloader = "uefi";
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
    };
    services = {
      plex = true;
      avahi = true;
      coredns = true;
      samba = true;
      satisfactoryServer = false;
      ssh = true;
      sshGuard = true;
      synapse = true;
      gitea = true;
      torrent = true;
      ddns = true;
      nginx = true;
    };
  };
}
