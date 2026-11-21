{ inputs, ... }:
{
  flake.nixosModules.unifiedChatOverlay = {
    imports = [ inputs.unified-chat-overlay.nixosModules.multichat-overlay ];

    services.multichat-overlay = {
      enable = true;
      listenAddress = "10.0.0.1";
      openFirewall = true;

      # Loopback is the default allow-list; browsers on the LAN need their
      # networks added explicitly or every route answers 403.
      allowedNetworks = [
        "127.0.0.0/8"
        "::1/128"
        "10.0.0.0/24"
        "fd00:beef::/64"
      ];
    };
  };
}
