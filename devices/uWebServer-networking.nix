{
  lib,
  ...
}:
{
  # ── Kernel forwarding & RA behaviour ────────────────────────────────────────
  # Disable global RA/autoconf so only WAN picks up the ISP prefix.
  # Forwarding must be on for both families so routed traffic passes through.
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;

    "net.ipv6.conf.all.accept_ra"   = 0;
    "net.ipv6.conf.all.autoconf"    = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    # WAN needs to accept the ISP's RA even though forwarding is on (hence "2").
    "net.ipv6.conf.WAN.accept_ra" = 2;
    "net.ipv6.conf.WAN.autoconf"  = 1;
  };

  # ── Stable interface names ───────────────────────────────────────────────────
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="40:8d:5c:54:89:96", NAME="WAN"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c0", NAME="LAN0"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c1", NAME="LAN1"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c2", NAME="LAN2"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="ac:16:2d:9a:17:c3", NAME="LAN3"
  '';

  # ── Firewall ─────────────────────────────────────────────────────────────────
  networking.nftables.enable = true;
  networking.firewall = {
    # LAN bridge is fully trusted.
    trustedInterfaces = [ "br0" ];

    # DHCPv6-PD client (WAN-facing); kept global because the firewall runs
    # before interface-specific rules for inbound WAN traffic.
    allowedUDPPorts = [ 546 ];

    interfaces."br0" = {
      allowedTCPPorts = [
        53  # DNS
        67  # DHCPv4 server
      ];
      allowedUDPPorts = [
        53  # DNS
        67  # DHCPv4 server
        547 # DHCPv6 server (stateful fallback for clients that need it)
      ];
    };
  };

  # ── systemd-networkd ─────────────────────────────────────────────────────────
  # This is the authoritative network config. The legacy networking.interfaces
  # block is intentionally absent — useNetworkd = true means networkd wins, and
  # having both causes confusing races.
  systemd.network = {
    enable = true;
    networks = {

      "10-wan" = {
        matchConfig.PermanentMACAddress = "40:8d:5c:54:89:96";
        networkConfig = {
          DHCP        = "yes";
          IPv6AcceptRA = true;
        };
        dhcpV6Config = {
          UseDelegatedPrefix = true;
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
      };

      "20-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          # Hand out the delegated WAN /64 sub-prefix to LAN clients via RA.
          DHCPPrefixDelegation = true;
          IPv6SendRA           = true;
          IPv6AcceptRA         = false;
        };
        # Static addresses: IPv4 gateway + ULA link-local-style address for
        # internal-only IPv6 (always works even when the ISP prefix is absent).
        address = [
          "10.0.0.1/24"
          "fd00:beef::1/64"
        ];
        # Advertise the ULA prefix unconditionally via RA.
        ipv6Prefixes = [
          { Prefix = "fd00:beef::/64"; }
        ];
        dhcpPrefixDelegationConfig = {
          # Also announce whatever /64 the ISP delegates to us.
          Announce = true;
          SubnetId = "auto";
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          # Clients use the router's ULA address as their DNS resolver.
          DNS = [ "fd00:beef::1" ];
        };
      };

    };
  };

  # ── Networking (bridge, NAT, general) ────────────────────────────────────────
  services.resolved.enable = false;
  networking = {
    useNetworkd = true;
    networkmanager.enable = lib.mkForce false;
    tempAddresses = "disabled";

    bridges."br0".interfaces = [ "LAN0" "LAN1" "LAN2" "LAN3" ];

    nat = {
      enable            = true;
      externalInterface = "WAN";
      internalInterfaces = [ "br0" ];
      internalIPs        = [ "10.0.0.0/24" ];
      forwardPorts = [
        # ── Minecraft: Vanilla (Java) ──────────────────────────────────────
        { sourcePort = 25565; proto = "tcp"; destination = "10.0.0.3:25565"; }
        # ── Minecraft: ATM7 ───────────────────────────────────────────────
        { sourcePort = 25566; proto = "tcp"; destination = "10.0.0.3:25566"; }
        # ── Minecraft: Create: Chronicles ─────────────────────────────────
        { sourcePort = 25568; proto = "tcp"; destination = "10.0.0.3:25568"; }
        # ── Minecraft: ATM10 – To the Sky ─────────────────────────────────
        { sourcePort = 25570; proto = "tcp"; destination = "10.0.0.3:25570"; }
        # ── Simple Voice Chat (ATM10) ──────────────────────────────────────
        { sourcePort = 24470; proto = "udp"; destination = "10.0.0.3:24470"; }
        { sourcePort = 24454; proto = "udp"; destination = "10.0.0.3:24454"; }
        # ── Minecraft: Vanilla Bedrock ────────────────────────────────────
        { sourcePort = 24455; proto = "udp"; destination = "10.0.0.3:24455"; }
        { sourcePort = 19132; proto = "udp"; destination = "10.0.0.3:19132"; }
        # ── Unreal Tournament '99 ─────────────────────────────────────────
        { sourcePort = 7777;  proto = "udp"; destination = "10.0.0.3:7777";  }
        { sourcePort = 7776;  proto = "udp"; destination = "10.0.0.3:7776";  }
        # ── Hytale ────────────────────────────────────────────────────────
        { sourcePort = 5520;  proto = "udp"; destination = "10.0.0.3:5520";  }
      ];
    };
  };

  # ── dnsmasq (DNS + DHCPv4 + DHCPv6/RA) ──────────────────────────────────────
  services.dnsmasq = {
    enable            = true;
    alwaysKeepRunning = true;
    settings = {
      interface = "br0";

      # Listen on loopback (both families) and the LAN bridge (both families).
      listen-address = "127.0.0.1,::1,10.0.0.1,fd00:beef::1";

      # Local domain
      domain       = "krutonium.ca,10.0.0.0/24";
      expand-hosts = true;

      # Upstream resolvers — if both are down, something very bad has happened.
      server = [ "1.1.1.1" "8.8.8.8" ];

      # ── DHCPv4 ────────────────────────────────────────────────────────────
      # Range starts at .2; .1 is the router itself.
      dhcp-range = 
	[ 
	  "10.0.0.2,10.0.0.254,5m"
 	  "::1000, ::ffff,constructor:br0,64,5m"
        ];
      dhcp-option = [
        "option:router,10.0.0.1"
        "option:classless-static-route,10.0.0.0/24,10.0.0.1"
      ];

      # ── DHCPv6 (stateful, ULA prefix) ─────────────────────────────────────
      # Clients that ignore RA (rare) can still get a ULA address via DHCPv6.
      # The ::1000–::ffff range leaves ::1–::fff for static assignments.
      # dhcp-range6 = [ "fd00:beef::1000,fd00:beef::ffff,64,5m" ];

      # ── Static DHCP leases ────────────────────────────────────────────────
      dhcp-host = [
        "ac:16:2d:9a:17:c5,10.0.0.1"   # uWebServer   (this machine)
        "18:C0:4D:04:05:E7,10.0.0.2"   # uGamingPC
        "30:9c:23:d3:06:fd,10.0.0.3"   # uServerHost
        "44:6D:57:BB:47:B0,10.0.0.4"   # uMsiLaptop (Wi-Fi)
        "d8:cb:8a:80:26:93,10.0.0.5"   # uMsiLaptop (Wired)
        # 10.0.0.6 intentionally reserved
        "14:EB:B6:58:A1:D4,10.0.0.7"   # Archer Router
        "b0:68:e6:97:f4:37,10.0.0.8"   # Printer
        "50:5A:65:61:DB:3B,10.0.0.9"   # Steam Deck
      ];

      # ── Local DNS overrides ───────────────────────────────────────────────
      address = [
        "/krutonium.ca/10.0.0.1"
        "/krutonium.ca/fd00:beef::1"
        "/BRWB068E697F437.local/10.0.0.8"
      ];
    };
  };
}
