self: super: {
  linuxPackages_nvidia = super.linuxPackages_zen.extend (
    selfnv: supernv:
    let
      # Current Target Driver
      base = selfnv.nvidiaPackages.mkDriver {
        version = "580.76.05";
        sha256_64bit = "sha256-IZvmNrYJMbAhsujB4O/4hzY8cx+KlAyqh7zAVNBdl/0=";
        openSha256 = "sha256-xEPJ9nskN1kISnSbfBigVaO6Mw03wyHebqQOQmUg/eQ=";
        settingsSha256 = "sha256-ll7HD7dVPHKUyp5+zvLeNqAb6hCpxfwuSyi+SAXapoQ=";
        persistencedSha256 = "sha256-bs3bUi8LgBu05uTzpn2ugcNYgR5rzWEPaTlgm0TIpHY=";
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
