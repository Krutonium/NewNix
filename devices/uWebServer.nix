{ config, pkgs, lib, ... }:
let
  kernel = pkgs.linuxPackages;
  Hostname = "uWebServer";
  Internet_In = "enp4s0";
in
{
  networking.firewall.allowedTCPPorts = [ 25565 25566 50056 ];
  networking.firewall.allowedUDPPorts = [ 50056 67 68 ];
  #networking.firewall.enable = lib.mkForce false;
  boot = {
    kernelPackages = kernel;
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;
    };
  };
  networking = {
    hostName = Hostname;
    nameservers = [ "8.8.8.8" "2001:4860:4860:0:0:0:0:8888" ];
    nat = {
      enable = true;
      externalInterface = "enp4s0";
      internalInterfaces = [ "enp2s0f0" ];
      internalIPs = [ "10.0.0.0/24" ];
      forwardPorts = [{
        sourcePort = "1:65565";
        loopbackIPs = [ "99.248.154.165" ];
        destination = "10.0.0.1";
      }];
    };
    #vlans = {
    #wan = {
    #  id = 10;
    #  interface = Internet_In;
    #};
    #lan_1 = {
    #  id = 20;
    #  interface = "enp2s0f0";
    #};
    #lan_wifi = {
    #  id = 30;
    #  interface = "enp3s0f1";
    #};
    #};
    interfaces = {
      "enp4s0" = {
        ipv4.addresses = [{ address = "192.168.0.10"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "2607:fea8:7a5f:2a00::9b46"; prefixLength = 128; }];
        useDHCP = false;
      };
      "enp2s0f0" = {
        ipv4.addresses = [{ address = "10.0.0.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fd00:0:0:1::1"; prefixLength = 64; }];
        useDHCP = false;
      };
      #"lan_wifi" = {
      #  useDHCP = false;
      #};
    };
    defaultGateway = { address = "192.168.0.1"; interface = Internet_In; };
    defaultGateway6 = { address = "fe80::1"; interface = Internet_In; };
    tempAddresses = "disabled";

    #nftables = {
    #  ruleset = ''
    #    table inet filter {
    #      flowtable f {
    #        hook ingress priority 0;
    #        devices = { enp4s0, enp2s0f0 };
    #      };
    #      
    #      chain output {
    #        type filter hook output priority 100; policy accept;
    #      };
    #
    #      chain input {
    #        type filter hook input priority filter; policy drop;
    #        
    #        iifname {
    #          "enp2s0f0",
    #        } counter accept
    #        
    #        
    #      };
    #  '';
    #};
  };

  services.dhcpd4 = {
    enable = true;
    interfaces = [ "enp2s0f0" ];
    extraConfig = ''
      option domain-name-servers 8.8.8.8, 1.1.1.1, 8.8.4.4, 1.0.0.1;
      option subnet-mask 255.255.255.0;
      option routers 10.0.0.1;
      subnet 10.0.0.0 netmask 255.0.0.0 {
        range 10.0.0.2 10.0.0.254;
        interface enp2s0f0;
      }

    '';
    #machines = { };
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
