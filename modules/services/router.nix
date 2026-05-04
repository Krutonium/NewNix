{ ... }:
{
  flake.nixosModules.router =
    { lib, ... }:
    {
      networking.domain = "krutonium.ca";
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "net.ipv6.conf.all.accept_ra" = 0;
        "net.ipv6.conf.all.autoconf" = 0;
        "net.ipv6.conf.all.use_tempaddr" = 0;
        "net.ipv6.conf.WAN.accept_ra" = 2;
        "net.ipv6.conf.WAN.autoconf" = 1;
      };

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="40:8d:5c:54:89:96", NAME="WAN"
        ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c0", NAME="LAN0"
        ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c1", NAME="LAN1"
        ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c2", NAME="LAN2"
        ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c3", NAME="LAN3"
      '';

      networking.nftables.enable = true;
      networking.firewall = {
        checkReversePath = "loose";
        trustedInterfaces = [ "br0" ];
        allowedUDPPorts = [ 546 ];
        interfaces."br0" = {
          allowedTCPPorts = [ 53 67 ];
          allowedUDPPorts = [ 53 67 547 ];
        };
        extraInputRules = ''
          ip6 daddr fd00:beef::3 tcp dport { 25565, 25566, 25568, 25570 } accept
          ip6 daddr fd00:beef::3 udp dport { 24470, 24454, 24455, 19132, 7777, 7776, 5520 } accept
        '';
      };

      systemd.network = {
        enable = true;
        networks = {
          "10-wan" = {
            matchConfig.PermanentMACAddress = "40:8d:5c:54:89:96";
            networkConfig = {
              DHCP = "yes";
              IPv6AcceptRA = true;
            };
            dhcpV6Config = {
              UseDelegatedPrefix = true;
              WithoutRA = "solicit";
              PrefixDelegationHint = "::/60";
            };
            ipv6AcceptRAConfig = {
              UseAutonomousPrefix = true;
              UseOnLinkPrefix = true;
            };
            linkConfig.RequiredForOnline = "routable";
          };

          "20-br0" = {
            matchConfig.Name = "br0";
            networkConfig = {
              DHCPPrefixDelegation = true;
              IPv6SendRA = true;
              IPv6AcceptRA = false;
            };
            address = [
              "10.0.0.1/24"
              "fd00:beef::1/64"
            ];
            ipv6Prefixes = [
              { Prefix = "fd00:beef::/64"; }
            ];
            dhcpPrefixDelegationConfig = {
              Announce = true;
              SubnetId = "auto";
            };
            ipv6SendRAConfig = {
              EmitDNS = true;
              DNS = [ "fd00:beef::1" ];
              Managed = true;
            };
          };
        };
      };

      services.resolved.enable = false;
      networking = {
        useNetworkd = true;
        networkmanager.enable = lib.mkForce false;
        tempAddresses = "disabled";

        bridges."br0".interfaces = [ "LAN0" "LAN1" "LAN2" "LAN3" ];

        nat = {
          enable = true;
          externalInterface = "WAN";
          internalInterfaces = [ "br0" ];
          internalIPs = [ "10.0.0.0/24" ];
          forwardPorts = [
            { sourcePort = 25565; proto = "tcp"; destination = "10.0.0.3:25565"; }
            { sourcePort = 25566; proto = "tcp"; destination = "10.0.0.3:25566"; }
            { sourcePort = 25568; proto = "tcp"; destination = "10.0.0.3:25568"; }
            { sourcePort = 25570; proto = "tcp"; destination = "10.0.0.3:25570"; }
            { sourcePort = 24470; proto = "udp"; destination = "10.0.0.3:24470"; }
            { sourcePort = 24454; proto = "udp"; destination = "10.0.0.3:24454"; }
            { sourcePort = 24455; proto = "udp"; destination = "10.0.0.3:24455"; }
            { sourcePort = 19132; proto = "udp"; destination = "10.0.0.3:19132"; }
            { sourcePort = 7777;  proto = "udp"; destination = "10.0.0.3:7777";  }
            { sourcePort = 7776;  proto = "udp"; destination = "10.0.0.3:7776";  }
            { sourcePort = 5520;  proto = "udp"; destination = "10.0.0.3:5520";  }
          ];
        };
      };

      services.dnsmasq = {
        enable = true;
        alwaysKeepRunning = true;
        settings = {
          dhcp-leasefile = "/persist/dnsmasq.leases";
          interface = "br0";
          listen-address = "127.0.0.1,::1,10.0.0.1,fd00:beef::1";
          server = [ "1.1.1.1" "8.8.8.8" ];
          dhcp-range = [
            "10.0.0.2,10.0.0.254,5m"
            "::1000, ::ffff,constructor:br0,64,5m"
          ];
          dhcp-option = [
            "option:router,10.0.0.1"
            "option:classless-static-route,10.0.0.0/24,10.0.0.1"
          ];
          dhcp-host = [
            "ac:16:2d:9a:17:c5,uWebServer,10.0.0.1,[fd00:beef::1]"
            "18:C0:4D:04:05:E7,uGamingPC,10.0.0.2,[fd00:beef::2]"
            "30:9c:23:d3:06:fd,uServerHost,10.0.0.3,[fd00:beef::3]"
            "44:6D:57:BB:47:B0,uMsiLaptop,10.0.0.4,[fd00:beef::4]"
            "d8:cb:8a:80:26:93,uMsiLaptopW,10.0.0.5,[fd00:beef::5]"
            "14:EB:B6:58:A1:D4,Archer,10.0.0.7,[fd00:beef::7]"
            "b0:68:e6:97:f4:37,Printer,10.0.0.8,[fd00:beef::8]"
            "50:5A:65:61:DB:3B,deck,10.0.0.9,[fd00:beef::9]"
          ];
          address = [
            "/BRWB068E697F437.local/10.0.0.8"
            "/krutonium.ca/10.0.0.1"
            "/krutonium.ca/fd00:beef::1"
          ];
          host-record = [
            "uWebServer.krutonium.ca,10.0.0.1,fd00:beef::1"
            "uGamingPC.krutonium.ca,10.0.0.2,fd00:beef::2"
            "uServerHost.krutonium.ca,10.0.0.3,fd00:beef::3"
            "uMsiLaptop.krutonium.ca,10.0.0.4,fd00:beef::4"
            "Archer.krutonium.ca,10.0.0.7,fd00:beef::7"
          ];
        };
      };
    };
}