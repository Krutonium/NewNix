{ ... }: {
  flake.overlays.dolphin-emu-git = final: prev: {
    dolphin-emu = (prev.dolphin-emu.override {
      sdl3 = prev.sdl3.overrideAttrs (_: {
        version = "unstable-2025-06-16";
        src = prev.fetchFromGitHub {
          owner = "libsdl-org";
          repo = "SDL";
          rev = "0fa422231de7115f9378c8efcf7e5ddfee47e916";
          hash = "sha256-QZcppvQTfA75Vmg23GLup96nuOmOl+Sw6QOCeFoiGV8=";
        };
      });
    }).overrideAttrs (oldAttrs: {
      version = "144d194";

      src = prev.fetchFromGitHub {
        owner = "dolphin-emu";
        repo = "dolphin";
        rev = "144d19433aa734c19c34e5978a1b817d2aa12663";
        hash = "sha256-yKwASLtxkgHsSb982grVoGnZXYKUNP5mmW5VEWFeoYM=";
        fetchSubmodules = true;
        leaveDotGit = true;
        postFetch = ''
          pushd $out
          git rev-parse HEAD 2>/dev/null >$out/COMMIT
          find $out -name .git -print0 | xargs -0 rm -rf
          popd
        '';
      };

      cmakeFlags = map (flag:
        if flag == "-DDOLPHIN_WC_DESCRIBE=${oldAttrs.version}"
        then "-DDOLPHIN_WC_DESCRIBE=144d194"
        else flag
      ) oldAttrs.cmakeFlags;
    });
  };
}