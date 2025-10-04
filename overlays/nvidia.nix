self: super: {
  # Provide a helper to apply the patched NVIDIA driver to any linuxPackages set

  # To use: `kernel = pkgs.nvidiaFor pkgs.linuxPackages_the_version;`
  nvidiaFor = linuxPackages:
    linuxPackages.extend (
      selfnv: supernv:
      let
        base = selfnv.nvidiaPackages.mkDriver {
          # Update Procedure:
          # - Update version number
          # - Remove all hashes
          # - Build repeatedly until all hashes are satisfied.
          version = "580.82.09";
          sha256_64bit = "sha256-Puz4MtouFeDgmsNMKdLHoDgDGC+QRXh6NVysvltWlbc=";
          sha256_aarch64 = "sha256-6tHiAci9iDTKqKrDIjObeFdtrlEwjxOHJpHfX4GMEGQ=";
          openSha256 = "sha256-YB+mQD+oEDIIDa+e8KX1/qOlQvZMNKFrI5z3CoVKUjs=";
          settingsSha256 = "sha256-um53cr2Xo90VhZM1bM2CH4q9b/1W2YOqUcvXPV6uw2s=";
          persistencedSha256 = "sha256-lbYSa97aZ+k0CISoSxOMLyyMX//Zg2Raym6BC4COipU=";
        };

        patched =
          let
            pkgAfterFbc =
              if builtins.hasAttr base.version super.pkgs.nvidia-patch-list.fbc then
                super.pkgs.nvidia-patch.patch-fbc base
              else
                base;
          in
          if builtins.hasAttr base.version super.pkgs.nvidia-patch-list.nvenc then
            super.pkgs.nvidia-patch.patch-nvenc pkgAfterFbc
          else
            pkgAfterFbc;
      in {
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
