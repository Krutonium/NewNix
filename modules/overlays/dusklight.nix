{ ... }: {
  flake.overlays.dusklight = final: prev: {
    dusklight = (
      prev.dusklight.override {
        sdl3 = prev.sdl3.overrideAttrs (_: {
          version = "unstable-2025-06-16";
          src = prev.fetchFromGitHub {
            owner = "libsdl-org";
            repo = "SDL";
            rev = "ae3869bf85bc08c1d6bfc219dd5fde27fe18181d";
            hash = "sha256-Z2Bl5GCe0+N6VxTphV15FkoL6O3jONhv0WHJIGW9z50=";
          };
        });
      }
    ).overrideAttrs (_: {
      dontStrip = false;
      stripAllList = [ "share" ];
    });
  };
}