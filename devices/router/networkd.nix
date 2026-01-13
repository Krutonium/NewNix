{ ... }:
let
  timestamp = "2026-01-10 00:00:00 UTC";
in
{
  systemd.network = {
    enable = true;
    config = {
      networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv6PrivacyExtensions = false;
      };
      dhcpV4Config = {
        ClientIdentifier = "duid";
        DUIDType = "link-layer-time:${timestamp}";
      };
      dhcpV6Config = {
        DUIDType = "link-layer-time:${timestamp}";
      };
    };
  };
  # Disable Legacy DHCP
  networking.useDHCP = false;
}