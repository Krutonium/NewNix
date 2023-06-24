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
    # We're not using NetworkManager, as it apparently kinda just dies when given access to the raw internet.
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
    };
    interfaces = {
      "enp4s0" = {
        #We're getting the IP dynamically from the ISP.
        useDHCP = true;
      };
      "bridge" = {
        # For now we're setting this statically, but I don't think there is any reason we couldn't use DHCP here.
        ipv4.addresses = [{ address = "10.0.0.1"; prefixLength = 24; }];
        useDHCP = false;
      };
    };
    tempAddresses = "disabled";
  };

  services.dnsmasq = {
    enable = false;
    alwaysKeepRunning = true;
    extraConfig = ''
      interface = bridge;
      domain = krutonium.ca, 10.0.0.1;
      dhcp-range = 10.0.0.10, 10.0.0.254, 5m;
      dhcp-option = 3,10.0.0.1;
      dhcp-option = 6,1.1.1.1,8.8.8.8;
      dhcp-option = 121,10.0.0.0/24,10.0.0.1;
      dhcp-range = ::f,::ff,constructor:bridge;
      dhcp-host = F8:16:54:A5:A5:10.0.0.4;
    '';
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
