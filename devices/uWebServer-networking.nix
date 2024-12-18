{ config, pkgs, lib, ... }:
{
  # Enable IPv4 and IPv6 packet forwarding and IPv6 autoconfiguration
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1; 
    "net.ipv6.conf.all.accept_ra" = 2;    # Accept router advertisements even when forwarding is enabled
    "net.ipv6.conf.all.request_prefix" = 1; # Request prefix delegation
    "net.ipv6.conf.all.autoconf" = 1;     # Enable stateless autoconfiguration
    "net.ipv6.conf.all.use_tempaddr" = 0; # Disable temporary addresses
  };

  # Map network interfaces to consistent names based on MAC addresses
  services = {
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="40:8d:5c:54:89:96", NAME="WAN"
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c0", NAME="LAN0"
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c1", NAME="LAN1" 
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c2", NAME="LAN2"
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c3", NAME="LAN3"
    '';
  };

  # Enable nftables firewall
  networking.nftables.enable = true;
  networking.firewall.allowedUDPPorts = [ 546 547 ]; # Allow DHCPv6 client and server
  networking.firewall.trustedInterfaces = [ "br0" ];

  # Configure systemd-networkd
  systemd.network = {
    enable = true;
    networks = {
      "wan" = {
        matchConfig.PermanentMACAddress = "40:8d:5c:54:89:96";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = "yes";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        dhcpV6Config = {
          WithoutRA = "solicit";
          PrefixDelegationHint = "::/56"; # Request a larger prefix
          UseDelegatedPrefix = true;
          UseDNS = true;
        };
        ipv6AcceptRAConfig = {
          DHCPv6Client = "yes";
          UseDNS = true;
        };
      };
      "br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCPPrefixDelegation = true;
          IPv6SendRA = true;
          IPv6AcceptRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = "fd00::1"; # Point to local dnsmasq for IPv6 DNS using ULA address
        };
      };
    };
  };

  # Disable systemd-resolved as we're using dnsmasq
  services.resolved.enable = false;

  networking = {
    # Disable NetworkManager in favor of systemd-networkd
    networkmanager.enable = lib.mkForce false;
    useNetworkd = true;

    # Create bridge interface for LAN ports
    bridges = {
      "br0" = {
        interfaces = [ "LAN0" "LAN1" "LAN2" "LAN3" ];
      };
    };

    # Configure NAT for IPv4 and IPv6
    nat = {
      enable = true;
      externalInterface = "WAN";
      internalInterfaces = [ "br0" ];
      internalIPs = [ "10.0.0.0/24" ];
      enableIPv6 = true;
      # This will be automatically configured from prefix delegation
      internalIPv6s = [ "::/64" ];
    };

    # Configure network interfaces
    interfaces = {
      "WAN" = {
        useDHCP = true; # Get IPv4 and IPv6 configuration from ISP
      };
      "br0" = {
        ipv4.addresses = [{ address = "10.0.0.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fd00::1"; prefixLength = 64; }]; # Add ULA address for local IPv6
        useDHCP = false;
        macAddress = "ac:16:2d:9a:17:c5";
      };
    };
    tempAddresses = "disabled";
  };

  # Enable IPv6 router advertisements
  services.radvd = {
    enable = true;
    config = ''
      interface br0 {
        AdvSendAdvert on;
        AdvManagedFlag on;
        AdvOtherConfigFlag on;
        # This prefix will be automatically configured from delegation
        prefix ::/64 {
          AdvOnLink on;
          AdvAutonomous on;
          AdvRouterAddr on;
        };
        # Add ULA prefix for local addressing
        prefix fd00::/64 {
          AdvOnLink on;
          AdvAutonomous on;
          AdvRouterAddr on;
        };
        RDNSS fd00::1 {
          AdvRDNSSLifetime 3600;
        };
      };
    '';
  };

  # Configure firewall to allow DNS and DHCP on LAN
  networking.firewall.interfaces."br0".allowedTCPPorts = [ 53 67 ];
  networking.firewall.interfaces."br0".allowedUDPPorts = [ 53 67 547 ];

  # Configure DHCP and DNS server
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = "br0";
      # Local domain configuration
      domain = "krutonium.ca,10.0.0.1";
      # DHCP range with 5 minute lease time
      dhcp-range = "10.0.0.1,10.0.0.254,5m";
      # Configure router and static routes
      dhcp-option = [ 
        "option:router,10.0.0.1" 
        "option:classless-static-route,10.0.0.0/24,10.0.0.1" 
      ];
      # Static DHCP assignments
      dhcp-host = [
        "ac:16:2d:9a:17:c5,10.0.0.1"    # uWebServer
        "18:C0:4D:04:05:E7,10.0.0.2"    # uGamingPC / Linux
        "30:9c:23:d3:06:fd,10.0.0.3"    # uWindowsPC / Gaming/Windows
        "F8:16:54:A5:A5:91,10.0.0.4"    # uMsiLaptop
        "14:EB:B6:58:A1:D4,10.0.0.7"    # Archer Router
        "b0:68:e6:97:f4:37,10.0.0.8"    # Printer
        "50:5A:65:61:DB:3B,10.0.0.9"    # SteamDeck
      ];
      # Listen on all local addresses including IPv6
      listen-address = "127.0.0.1,10.0.0.1,fd00::1";
      bind-interfaces = true;
      expand-hosts = true;
      # Enable IPv6 DNS caching
      cache-size = 1000;
      dns-forward-max = 150;
      # Upstream DNS servers (IPv4 and IPv6)
      server = [ 
        "1.1.1.1"
        "8.8.8.8"
        "2606:4700:4700::1111"  # Cloudflare IPv6
        "2001:4860:4860::8888"  # Google IPv6
      ];
      # Local DNS overrides
      address = [ 
        "/krutonium.ca/10.0.0.1" 
        "/BRWB068E697F437.local/10.0.0.8" 
      ];
    };
  };
}
