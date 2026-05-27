{ nixpkgs-arcmenu, ... }:
{
  flake.overlays.arcmenu = final: prev: {
    gnomeExtensions = prev.gnomeExtensions // {
      arcmenu = (import nixpkgs-arcmenu {
        inherit (prev) system config;
      }).gnomeExtensions.arcmenu;
    };
  };
}