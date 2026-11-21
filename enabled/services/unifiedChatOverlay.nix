{ inputs, ... }:
{
  flake.nixosModules.unifiedChatOverlay = {
    imports = [ inputs.unified-chat-overlay.nixosModules.multichat-overlay ];

    services.multichat-overlay = {
      enable = true;
      listenAddress = "10.0.0.1";
      openFirewall = true;
    };
  };
}
