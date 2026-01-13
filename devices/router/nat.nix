{ ... }:
{
  networking.nat = {
    enable = true;
    externalInterface = "wan0";
    internalInterfaces = [ "br0" ];
    forwardPorts = [
      {
        # Vanilla
        sourcePort = 25565;
        proto = "tcp";
        destination = "10.0.0.3:25565";
      }
      # Atm7
      {
        sourcePort = 25566;
        proto = "tcp";
        destination = "10.0.0.3:25566";
      }
      {
        # Create: Chronicles
        sourcePort = 25568;
        proto = "tcp";
        destination = "10.0.0.3:25568";
      }
      # AtM10: To the Sky
      {
        sourcePort = 25570;
        proto = "tcp";
        destination = "10.0.0.3:25570";
      }
      # AtM10: To the Sky / Simple Voice Chat
      {
        sourcePort = 24470;
        proto = "udp";
        destination = "10.0.0.3:24470";
      }
      {
        sourcePort = 24454;
        proto = "udp";
        destination = "10.0.0.3:24454";
      }
      # Vanilla Bedrock
      {
        sourcePort = 24455;
        proto = "udp";
        destination = "10.0.0.3:24455";
      }
      # Vanilla Bedrock
      {
        sourcePort = 19132;
        proto = "udp";
        destination = "10.0.0.3:19132";
      }
    ];
  };
}
