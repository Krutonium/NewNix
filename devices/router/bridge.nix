{ config, lib, pkgs, ... }:
let
  subnet = "10.0.0"; # The /24 IPv4 Prefix to Use
in
{
  systemd.network = {
    netdevs."10-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
    };
    networks."30-br0" = {
      matchConfig.Name = "br0";
      # linkConfig.RequiredForOnline = "routable";
      linkConfig.RequiredForOnline = false;
      networkConfig = {
        DHCP = false;
        DHCPServer = true;
        IPv6AcceptRA = false;
        IPv6SendRA = true;
        DHCPPrefixDelegation = true;
        ConfigureWithoutCarrier = true;
      };
      bridgeConfig = {
      };

      # IPv4
      dhcpServerConfig = {
        ServerAddress = "${subnet}.1/24";
        PoolOffset = 64;
        # UplinkInterface = "wan0";
        DNS = "${subnet}.1";
      };
      dhcpServerStaticLeases = [
        { MACAddress = "ac:16:2d:9a:17:c5"; Address = "${subnet}.1"; } # uWebServer
        { MACAddress = "18:C0:4D:04:05:E7"; Address = "${subnet}.2"; } # uGamingPC
        { MACAddress = "30:9c:23:d3:06:fd"; Address = "${subnet}.3"; } # uServerHost
        { MACAddress = "44:6D:57:BB:47:B0"; Address = "${subnet}.4"; } # uMsiLaptop
        { MACAddress = "00:90:a2:aa:cd:06"; Address = "${subnet}.5"; } # Kobo
        { MACAddress = "14:EB:B6:58:A1:D4"; Address = "${subnet}.7"; } # Archer AP
        { MACAddress = "b0:68:e6:97:f4:37"; Address = "${subnet}.8"; } # Brother Printer
        { MACAddress = "50:5A:65:61:DB:3B"; Address = "${subnet}.9"; } # SteamDeck
      ];

      # IPv6
      dhcpPrefixDelegationConfig = {
        UplinkInterface = "wan0";
        Announce = true;
        Assign = true;
        Token = "::1111";
      };
      ipv6SendRAConfig = {
        DNS = "_link_local";
        EmitDomains = false;
      };
    };
  };
  # Open DHCP Port
  networking.firewall.interfaces."br0".allowedUDPPorts = [ 67 ];
}