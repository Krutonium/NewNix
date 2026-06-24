{ ... }: {
  flake.overlays.sdl3 = final: prev: {
    sdl3 = prev.sdl3.overrideAttrs (_: {
      version = "unstable-2026-06-24";
      src = prev.fetchFromGitHub {
        owner = "libsdl-org";
        repo = "SDL";
        rev = "0fa422231de7115f9378c8efcf7e5ddfee47e916";
        hash = "sha256-QZcppvQTfA75Vmg23GLup96nuOmOl+Sw6QOCeFoiGV8=";
      };
      doCheck = false;
    });
  };
}