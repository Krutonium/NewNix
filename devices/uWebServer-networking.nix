{ config, pkgs, lib, ... }:
{
  systemd.services =
    let
      dependency = [ "dnsmasq.service" ];
    in
    lib.mapAttrs'
      (name: _: lib.nameValuePair "acme-${name}" {
        requires = dependency;
        after = dependency;
      })
      config.security.acme.certs;


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
  networking.nftables.enable = true;
  networking.firewall.allowedUDPPorts = [ 546 ]; #DHCPv6-PD
  networking.firewall.trustedInterfaces = [ "br0" ];
  systemd.network = {
    enable = true;
    networks = {
      "wan" = {
        matchConfig.PermanentMACAddress = "40:8d:5c:54:89:96";
        networkConfig = {
          #IPv6AcceptRA = true;
          DHCP = "yes";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        #dhcpV6Config = {
        #  WithoutRA = "solicit";
        #  PrefixDelegationHint = "::/64";
        #};
        #ipv6SendRAConfig = {
        #  Managed = true;
        #};
        #ipv6AcceptRAConfig = {
        #  DHCPv6Client = "yes";
        #};
      };
      "br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCPPrefixDelegation = true;
          #IPv6SendRA = true;
          #IPv6AcceptRA = true;
        };
        #ipv6SendRAConfig = {
        #  EmitDNS = true;
        #  DNS = "2001:4860:4860::8888";
        #};
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
      "br0" = {
        interfaces = [ "LAN0" "LAN1" "LAN2" "LAN3" ];
        # All ports on the Card are part of the LAN
      };
    };
    nat = {
      enable = true;
      externalInterface = "WAN";
      internalInterfaces = [ "br0" ];
      internalIPs = [ "10.0.0.0/24" ];
      forwardPorts =
      [
        {
          sourcePort = 25565;
          proto = "tcp";
          destination = "10.0.0.3";
        }
        {
          sourcePort = 25566;
          proto = "tcp";
          destination = "10.0.0.3";
        }
      ];
      #enableIPv6 = true;
      #internalIPv6s = [ "2001:db8:1234:5678::/64" ];
    };
    interfaces = {
      "WAN" = {
        #We're getting the IP dynamically from the ISP.
        useDHCP = true;
      };
      "br0" = {
        # For now we're setting this statically, but I don't think there is any reason we couldn't use DHCP here.
        ipv4.addresses = [{ address = "10.0.0.1"; prefixLength = 24; }];
        useDHCP = false;
        macAddress = "ac:16:2d:9a:17:c5";
      };
    };
    tempAddresses = "disabled";
  };

  services.radvd = {
    enable = false;
    config = ''
      interface br0 {
        AdvSendAdvert on;
        prefix 2001:db8:1234:5678::/64 { };
      };
    '';
  };

  networking.firewall.interfaces."br0".allowedTCPPorts = [ 53 67 ];
  networking.firewall.interfaces."br0".allowedUDPPorts = [ 53 67 ];
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = "br0";
      # Domain
      domain = "krutonium.ca,10.0.0.1";
      # DHCP Range, 5 Minute expire
      dhcp-range = "10.0.0.1,10.0.0.254,5m";
      # DHCP Options: Router Advertise at 10.0.0.1, and a static route at 10.0.0.1 for internet access
      dhcp-option = [ "option:router,10.0.0.1" "option:classless-static-route,10.0.0.0/24,10.0.0.1" ];
      # Statically Allocated Addresses
      dhcp-host = [
        # uWebServer
        "ac:16:2d:9a:17:c5,10.0.0.1"
        # uGamingPC / Linux
        "18:C0:4D:04:05:E7,10.0.0.2"
        # uWindowsPC / Gaming/Windows
        "30:9c:23:d3:06:fd,10.0.0.3"
        # uMsiLaptop
        "F8:16:54:A5:A5:91,10.0.0.4"
        # Archer Router
        "14:EB:B6:58:A1:D4,10.0.0.7"
        # Printer
        "b0:68:e6:97:f4:37,10.0.0.8"
        # SteamDeck
        "50:5A:65:61:DB:3B,10.0.0.9"
        # 5 and 6 intentionally missing for now.
      ];
      # Listens to br0
      listen-address = "::1,127.0.0.1,10.0.0.1";
      expand-hosts = true; #I *think* that's how that'd work?
      # DNS Servers:
      server = [ "1.1.1.1" "8.8.8.8" ]; # If both are down, an apocalypse is occuring.
      # Routes traffic to my domain to my server
      address = [
        "/krutonium.ca/10.0.0.1"
        "/BRWB068E697F437.local/10.0.0.8"
      ];
    };
  };
}
