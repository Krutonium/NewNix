{ ... }:
{
  systemd.network = {
    links."10-wan" = {
      matchConfig.PermanentMACAddress = "40:8d:5c:54:89:96";
      linkConfig.Name = "wan";
    };
    networks."20-wan" = {
      matchConfig.Name = "wan";
      linkConfig.RequiredForOnline = "routable";
      networkConfig = {
        DHCP = "ipv4";
        IPMasquerade = "ipv4";
        IPv6AcceptRA = true;
      };
      dhcpV4Config = {
        Anonymize = false;
        UseDNS = false;
        UseNTP = false;
      };
      dhcpV6Config = {
        UseDNS = false;
        UseNTP = false;
        UseDelegatedPrefix = true;
      };
      ipv6AcceptRAConfig = {
        Token = "eui64";
        UseDNS = false;
      };
    };
  };
}
