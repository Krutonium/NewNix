self: super: {
  linuxPackages_nvidia = super.linuxPackages_zen.extend (
    selfnv: supernv:
    let
      # Current Target Driver
      base = selfnv.nvidiaPackages.mkDriver {
        # Update Procedure:
        # Update version number
        # Remove all hashes
        # Build repeatedly until all hashes are satisfied.
        version = "580.82.07";
        sha256_64bit = "sha256-Bh5I4R/lUiMglYEdCxzqm3GLolQNYFB0/yJ/zgYoeYw=";
        openSha256 = "sha256-8/7ZrcwBMgrBtxebYtCcH5A51u3lAxXTCY00LElZz08=";
        settingsSha256 = "sha256-lx1WZHsW7eKFXvi03dAML6BoC5glEn63Tuiz3T867nY=";
        persistencedSha256 = "";
      };

      # Patch the driver (if patches are available)
      # to enable nvenc unlimited streams, and framebuffer capture
      patched =
        let
          pkgAfterFbc = if builtins.hasAttr base.version super.pkgs.nvidia-patch-list.fbc then super.pkgs.nvidia-patch.patch-fbc base else base;
        in
        if builtins.hasAttr base.version super.pkgs.nvidia-patch-list.nvenc then super.pkgs.nvidia-patch.patch-nvenc pkgAfterFbc else pkgAfterFbc;
    in
    {
      # And then override the nVidia Drivers with our new driver
      nvidiaPackages.mkDriver = supernv.nvidiaPackages.mkDriver;

      nvidiaPackages.stable = patched;
      nvidiaPackages.beta = patched;
      nvidiaPackages.production = patched;
      nvidia_x11 = patched;
    }
  );
}
