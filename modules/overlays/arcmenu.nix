{ self, inputs, ... }:
{
  flake.overlays.arcmenu = final: prev: {
    gnomeExtensions = prev.gnomeExtensions // {
      arcmenu = (import inputs.nixpkgs-arcmenu {
        inherit (prev) system config;
      }).gnomeExtensions.arcmenu;
    };
  };
}