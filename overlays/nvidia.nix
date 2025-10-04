self: super: {
  # Provide a helper to apply the patched NVIDIA driver to any linuxPackages set

  # To use: `kernel = pkgs.nvidiaFor pkgs.linuxPackages_the_version;`
  nvidiaFor =
    linuxPackages:
    linuxPackages.extend (
      selfnv: supernv:
      let
        base = selfnv.nvidiaPackages.mkDriver {
          # Update Procedure:
          # - Update version number
          # - Remove all hashes
          # - Build repeatedly until all hashes are satisfied.
          version = "580.95.05";
          sha256_64bit = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
          sha256_aarch64 = "sha256-zLRCbpiik2fGDa+d80wqV3ZV1U1b4lRjzNQJsLLlICk=";
          openSha256 = "sha256-RFwDGQOi9jVngVONCOB5m/IYKZIeGEle7h0+0yGnBEI=";
          settingsSha256 = "sha256-F2wmUEaRrpR1Vz0TQSwVK4Fv13f3J9NJLtBe4UP2f14=";
          persistencedSha256 = "sha256-QCwxXQfG/Pa7jSTBB0xD3lsIofcerAWWAHKvWjWGQtg=";
        };

        patched =
          let
            pkgAfterFbc = if builtins.hasAttr base.version super.pkgs.nvidia-patch-list.fbc then super.pkgs.nvidia-patch.patch-fbc base else base;
          in
          if builtins.hasAttr base.version super.pkgs.nvidia-patch-list.nvenc then super.pkgs.nvidia-patch.patch-nvenc pkgAfterFbc else pkgAfterFbc;
      in
      {
        # Preserve mkDriver passthrough
        nvidiaPackages.mkDriver = supernv.nvidiaPackages.mkDriver;

        # Override driver variants
        nvidiaPackages.stable = patched;
        nvidiaPackages.beta = patched;
        nvidiaPackages.production = patched;
        nvidia_x11 = patched;
      }
    );
}
