{ ... }:
{
  flake.nixosModules.minecraftPortForwards =
    { lib, config, ... }:
    with lib;
    let
      servers = config.minecraftServerData.servers;
      enabledServers = filter (s: s.enabled) servers;
      destination = "10.0.0.3";

      # Build one forward entry per port per protocol
      tcpForwards = concatMap (s:
        map (p: { sourcePort = p; proto = "tcp"; destination = "${destination}:${toString p}"; })
          ([ s.port ] ++ s.extraTCPPorts)
      ) enabledServers;

      udpForwards = concatMap (s:
        map (p: { sourcePort = p; proto = "udp"; destination = "${destination}:${toString p}"; })
          ([ s.port ] ++ s.extraUDPPorts)
      ) enabledServers;

      allTCPPorts = concatMap (s: [ s.port ] ++ s.extraTCPPorts) enabledServers;
      allUDPPorts = concatMap (s: [ s.port ] ++ s.extraUDPPorts) enabledServers;

      # nftables port set string, e.g. "{ 25565, 25568 }"
      toPortSet = ports: "{ ${concatStringsSep ", " (map toString ports)} }";
    in
    {
      networking.nat.forwardPorts = tcpForwards ++ udpForwards;

      networking.firewall.extraInputRules = ''
        ip6 daddr fd00:beef::3 tcp dport ${toPortSet allTCPPorts} accept
        ip6 daddr fd00:beef::3 udp dport ${toPortSet allUDPPorts} accept
      '';
    };
}
