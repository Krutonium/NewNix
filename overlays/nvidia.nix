self: super: {
  # Usage:
  # pkgs.nvidiaFor "580.105.88" pkgs.linuxPackages_6_11
  # pkgs.nvidiaFor "550.90.07" pkgs.linuxPackages_zen
  nvidiaFor =
    driverVersion: linuxPackages:
    linuxPackages.extend (
      selfnv: supernv:
      let
        # Mapping of known versions → hashes (expand when needed)
        knownVersions = {
          "580.119.02" = {
            sha256_64bit = "sha256-gCD139PuiK7no4mQ0MPSr+VHUemhcLqerdfqZwE47Nc=";
            openSha256 = "sha256-l3IQDoopOt0n0+Ig+Ee3AOcFCGJXhbH1Q1nh1TEAHTE=";
            settingsSha256 = "sha256-sI/ly6gNaUw0QZFWWkMbrkSstzf0hvcdSaogTUoTecI=";
            persistencedSha256 = "sha256-j74m3tAYON/q8WLU9Xioo3CkOSXfo1CwGmDx/ot0uUo=";
          };
          "590.44.01" = {
            sha256_64bit = "sha256-VbkVaKwElaazojfxkHnz/nN/5olk13ezkw/EQjhKPms=";
            openSha256 = "sha256-ft8FEnBotC9Bl+o4vQA1rWFuRe7gviD/j1B8t0MRL/o=";
            settingsSha256 = "sha256-wVf1hku1l5OACiBeIePUMeZTWDQ4ueNvIk6BsW/RmF4=";
            persistencedSha256 = "sha256-nHzD32EN77PG75hH9W8ArjKNY/7KY6kPKSAhxAWcuS4=";
          };
        };

        hashes = if builtins.hasAttr driverVersion knownVersions then knownVersions.${driverVersion} else throw "Unknown NVIDIA driver version: ${driverVersion} (add hashes to overlay)";

        base = selfnv.nvidiaPackages.mkDriver (
          {
            version = driverVersion;
            sha256_aarch64 = null;
          }
          // hashes
        );

        patched =
          let
            pkgAfterFbc = if builtins.hasAttr base.version super.pkgs.nvidia-patch-list.fbc then super.pkgs.nvidia-patch.patch-fbc base else base;
          in
          if builtins.hasAttr base.version super.pkgs.nvidia-patch-list.nvenc then super.pkgs.nvidia-patch.patch-nvenc pkgAfterFbc else pkgAfterFbc;
      in
      {
        # Preserve mkDriver passthrough
        nvidiaPackages.mkDriver = supernv.nvidiaPackages.mkDriver;

        # Override variants
        nvidiaPackages.stable = patched;
        nvidiaPackages.beta = patched;
        nvidiaPackages.production = patched;
        nvidia_x11 = patched;
      }
    );
}
