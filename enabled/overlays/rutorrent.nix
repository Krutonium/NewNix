{ ... }:
{
  # nixpkgs 26.05 still ships ruTorrent 5.2.10, which predates rTorrent
  # 0.16's XML-RPC changes (target argument, removed deprecated commands).
  # 5.3.x has explicit 0.16 compatibility maps, so pull it in until the
  # nixpkgs package is bumped.
  flake.overlays.rutorrent = final: prev: {
    rutorrent = prev.rutorrent.overrideAttrs (old: {
      version = "5.3.21";
      src = prev.fetchFromGitHub {
        owner = "Novik";
        repo = "ruTorrent";
        tag = "v5.3.21";
        hash = "sha256-Ji1gmV3Ac98fgmtZEqojyFyjJSqKrEC2TFuYxQHCHNY=";
      };
    });
  };
}
