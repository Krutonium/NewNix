{ inputs, ... }:
{
  flake.nixosModules.unifiedChatOverlay = {
    imports = [ inputs.unified-chat-overlay.nixosModules.multichat-overlay ];

    services.multichat-overlay = {
      enable = true;
    };
  };
}
