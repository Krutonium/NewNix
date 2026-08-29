{ inputs, ... }:
{
  flake.overlays.xwaylandvideobridge = final: prev: {
    xwaylandvideobridge = inputs.xwaylandvideobridge.packages.${final.system}.default;
  };
}