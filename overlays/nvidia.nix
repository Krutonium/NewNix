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
          version = "580.105.08";
          sha256_64bit = "sha256-2cboGIZy8+t03QTPpp3VhHn6HQFiyMKMjRdiV2MpNHU=";
          sha256_aarch64 = null;
          openSha256 = "sha256-FGmMt3ShQrw4q6wsk8DSvm96ie5yELoDFYinSlGZcwQ=";
          settingsSha256 = "sha256-YvzWO1U3am4Nt5cQ+b5IJ23yeWx5ud1HCu1U0KoojLY=";
          persistencedSha256 = "sha256-qh8pKGxUjEimCgwH7q91IV7wdPyV5v5dc5/K/IcbruI=";
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
