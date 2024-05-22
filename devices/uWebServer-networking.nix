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
  #Set up network interfaces to have *actually reliable names* (WOW!)
  services = {
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="40:8d:5c:54:89:96", NAME="WAN"
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c0", NAME="LAN0"
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c1", NAME="LAN1"
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c2", NAME="LAN2"
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c3", NAME="LAN3"
    '';
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
        interfaces = [ "LAN0" "LAN1" "LAN2" "LAN3" ];
        # All ports on the Card are part of the LAN
      };
    };
    nat = {
      enable = true;
      externalInterface = "WAN";
      internalInterfaces = [ "bridge" ];
      internalIPs = [ "10.0.0.0/24" ];
      enableIPv6 = true;
      internalIPv6s = [ "2001:db8:1234:5678::/64" ];
    };
    interfaces = {
      "WAN" = {
        #We're getting the IP dynamically from the ISP.
        useDHCP = true;
      };
      "bridge" = {
        # For now we're setting this statically, but I don't think there is any reason we couldn't use DHCP here.
        ipv4.addresses = [{ address = "10.0.0.1"; prefixLength = 24; }];
        useDHCP = false;
        macAddress = "ac:16:2d:9a:17:c5";
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
      interface=bridge                       #ip address
      domain=krutonium.ca,10.0.0.1           #domain and IP for the host
      dhcp-range=10.0.0.10,10.0.0.254,5m     #Range of DHCP IP's, and how long a lease should be
      dhcp-option=3,10.0.0.1                 #Primary DNS
      # dhcp-option=6,10.0.0.1,1.1.1.1,8.8.8.8 #Secondary DNS
      dhcp-option=121,10.0.0.0/24,10.0.0.1   #Static Route

      #uWebServer is hardcoded 10.0.0.1 above (It's IP is set outside of DHCP)
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

      # Jason's PC
      dhcp-host=d8:cb:8a:4f:75:54,10.0.0.10

      # DNS Stuff
      listen-address=::1,127.0.0.1,10.0.0.1 #Addresses it listens on from bridge
      expand-hosts                         
      server=1.1.1.1                        #Primary DNS
      server=8.8.8.8                        #Secondary DNS
      address=/krutonium.ca/10.0.0.1        #Send traffic headed to my domain to itself if it's on LAN
    '';
  };
}
