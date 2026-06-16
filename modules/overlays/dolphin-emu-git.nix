{ self, ... }: {
  flake.overlays.dolphin-emu-git = final: prev: {
    dolphin-emu = prev.dolphin-emu.overrideAttrs (oldAttrs: {
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

      # Replace the WC_DESCRIBE flag that embeds the version string.
      # All other flags (WC_REVISION, WC_BRANCH, etc.) come from preConfigure
      # or are version-independent, so they don't need touching.
      cmakeFlags = map (flag:
        if flag == "-DDOLPHIN_WC_DESCRIBE=${oldAttrs.version}"
        then "-DDOLPHIN_WC_DESCRIBE=144d194"
        else flag
      ) oldAttrs.cmakeFlags;
    });
  };
}