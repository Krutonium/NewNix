{ config, pkgs, lib, ... }:
{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;
  };
  networking = {
    networkmanager.enable = lib.mkForce false;
    useNetworkd = true;
    nameservers = [ "8.8.8.8" "2001:4860:4860:0:0:0:0:8888" ];

    bridges = {
      "bridge" = {
        interfaces = [ "enp2s0f0" "enp2s0f1" "enp2s0f2" "enp2s0f3" ];
        # All ports on the Card are part of the LAN
      };
    };
    nat = {
      enable = true;
      externalInterface = "enp4s0";
      internalInterfaces = [ "bridge" ];
      internalIPs = [ "10.0.0.0/24" ];
      #forwardPorts = [{
      #  sourcePort = "1:65535";
      #  loopbackIPs = [ "99.248.154.165" ];
      #  destination = "10.0.0.1:1-65535";
      #}];
    };
    interfaces = {
      "enp4s0" = {
        #ipv4.addresses = [{ address = "99.248.72.15"; prefixLength = 23; }];
        useDHCP = true;
      };
      "bridge" = {
        ipv4.addresses = [{ address = "10.0.0.1"; prefixLength = 24; }];
        useDHCP = false;
      };
    };
    #defaultGateway = { address = "192.168.0.1"; interface = Internet_In; };
    #defaultGateway6 = { address = "fe80::1"; interface = Internet_In; };
    tempAddresses = "disabled";
  };
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "bridge" ];
    extraConfig = ''
      option domain-name-servers 8.8.8.8, 1.1.1.1, 8.8.4.4, 1.0.0.1;
      option subnet-mask 255.255.255.0;
      option routers 10.0.0.1;
      subnet 10.0.0.0 netmask 255.0.0.0 {
        range 10.0.0.10 10.0.0.254;
        interface bridge;
      }
    '';
    machines = [
      {
        ethernetAddress = "18:C0:4D:04:05:E7";
        hostName = "uGamingPC";
        ipAddress = "10.0.0.2";
      }
      {
        ethernetAddress = "30:9c:23:d3:06:fd";
        hostName = "uRenderPC";
        ipAddress = "10.0.0.3";
      }
      {
        ethernetAddress = "F8:16:54:A5:A5:91";
        hostName = "uMsiLaptop";
        ipAddress = "10.0.0.4";
      }
      {
        ethernetAddress = "10:1F:74:0F:5A:E1";
        hostName = "uHPLaptop";
        ipAddress = "10.0.0.5";
      }
      {
        ethernetAddress = "00:1B:63:95:F1:2D";
        hostName = "uMacBookPro";
        ipAddress = "10.0.0.6";
      }
      {
        ethernetAddress = "14:EB:B6:58:A1:D4";
        hostName = "Archer";
        ipAddress = "10.0.0.7";
      }
    ];
  };
}
