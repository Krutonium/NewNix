{ config, pkgs, lib, ... }:
{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.accept_ra" = 2;
    "net.ipv6.conf.all.request_prefix" = 1;
    "net.ipv6.conf.all.autoconf" = 1;
    "net.ipv6.conf.all.use_tempaddr" = 0;
  };
  networking.firewall.allowedUDPPorts = [ 546 ]; #DHCPv6-PD
  systemd.network = {
    enable = true;
    networks = {
      "wan" = {
        matchConfig.PermanentMACAddress = "40:8d:5c:54:89:96";
        networkConfig = {
          IPv6AcceptRA = true;
          DHCP = "yes";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        dhcpV6Config = {
          WithoutRA = "solicit";
          PrefixDelegationHint = "::/64";
        };
        ipv6SendRAConfig = {
          Managed = true;
        };
        ipv6AcceptRAConfig = {
          DHCPv6Client = "yes";
        };
      };
      "bridge" = {
        matchConfig.Name = "bridge";
        networkConfig = {
          DHCPPrefixDelegation = true;
          IPv6AcceptRA = false;
          IPv6SendRA = true;
        };
      };
    };
  };
  services.resolved.enable = false;
  networking = {
    # We're not using NetworkManager, as it apparently kinda just dies when given access to the raw internet.
    networkmanager.enable = lib.mkForce false;
    useNetworkd = true;
    #nameservers = [ "10.0.0.1" ]; #Configured in Common

    bridges = {
      "bridge" = {
        interfaces = [ "enp13s0f0" "enp13s0f1" "enp13s0f2" "enp13s0f3" ];
        # All ports on the Card are part of the LAN
      };
    };
    nat = {
      enable = true;
      externalInterface = "enp5s0";
      internalInterfaces = [ "bridge" ];
      internalIPs = [ "10.0.0.0/24" ];
      enableIPv6 = true;
      internalIPv6s = [ "2001:db8:1234:5678::/64" ];
    };
    interfaces = {
      "enp5s0" = {
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

  services.radvd = {
    enable = true;
    config = ''
      interface bridge {
        AdvSendAdvert on;
        prefix 2001:db8:1234:5678::/64 { };
      };
    '';
  };

  networking.firewall.interfaces."bridge".allowedTCPPorts = [ 53 67 ];
  networking.firewall.interfaces."bridge".allowedUDPPorts = [ 53 67 ];
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    extraConfig = ''
      interface=bridge
      domain=krutonium.ca,10.0.0.1
      dhcp-range=10.0.0.10,10.0.0.254,5m
      dhcp-option=3,10.0.0.1
      dhcp-option=6,1.1.1.1,8.8.8.8
      dhcp-option=121,10.0.0.0/24,10.0.0.1

      #uWebServer is hardcoded 10.0.0.1 above
      #uGamingPC
      dhcp-host=18:C0:4D:04:05:E7,10.0.0.2
      #uRenderPC
      dhcp-host=30:9c:23:d3:06:fd,10.0.0.3
      #uMsiLaptop
      dhcp-host=F8:16:54:A5:A5:91,10.0.0.4
      #uHPLaptop
      dhcp-host=10:1F:74:0F:5A:E1,10.0.0.5
      #uMacBookPro
      dhcp-host=00:1B:63:95:F1:2D,10.0.0.6
      #Archer AP
      dhcp-host=14:EB:B6:58:A1:D4,10.0.0.7
      #Brother Printer
      dhcp-host=b0:68:e6:97:f4:37,10.0.0.8
      #SteamDeck/Deckster
      dhcp-host=50:5A:65:61:DB:3B,10.0.0.9


      # DNS Stuff
      listen-address=::1,127.0.0.1,10.0.0.1
      expand-hosts
      server=1.1.1.1
      server=8.8.8.8
      address=/krutonium.ca/10.0.0.1
    '';
  };
}
