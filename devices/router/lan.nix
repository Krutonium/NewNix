{
  lib,
  ...
}:
let
  ports = [
    "ac:16:2d:9a:17:c0"
    "ac:16:2d:9a:17:c1"
    "ac:16:2d:9a:17:c2"
    "ac:16:2d:9a:17:c3"
  ];
in
{
  systemd.network = {
    links = builtins.listToAttrs (
      lib.imap0 (i: port: {
        name = "10-lan${toString i}";
        value = {
          matchConfig.PermanentMACAddress = port;
          linkConfig.Name = "lan${toString i}";
        };
      }) ports
    );
    networks = builtins.listToAttrs (
      lib.imap0 (i: port: {
        name = "20-lan${toString i}";
        value = {
          matchConfig.Name = "lan${toString i}";
          linkConfig.RequiredForOnline = false;
          networkConfig = {
            Bridge = "br0";
            DHCP = false;
            IPv6AcceptRA = false;
            ConfigureWithoutCarrier = true;
          };
        };
      }) ports
    );
  };
}
