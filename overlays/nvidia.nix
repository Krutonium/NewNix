self: super: {
  linuxPackages_nvidia = super.linuxPackages_zen.extend (selfnv: supernv: {
    nvidiaPackages.mkDriver = supernv.nvidiaPackages.mkDriver;
    nvidiaPackages.stable = selfnv.nvidiaPackages.mkDriver {
      version = "580.76.05";
      sha256_64bit = "sha256-IZvmNrYJMbAhsujB4O/4hzY8cx+KlAyqh7zAVNBdl/0=";
      openSha256 = "sha256-xEPJ9nskN1kISnSbfBigVaO6Mw03wyHebqQOQmUg/eQ=";
      settingsSha256 = "sha256-ll7HD7dVPHKUyp5+zvLeNqAb6hCpxfwuSyi+SAXapoQ=";
      persistencedSha256 = "sha256-bs3bUi8LgBu05uTzpn2ugcNYgR5rzWEPaTlgm0TIpHY=";
    };
    nvidiaPackages.production = selfnv.nvidiaPackages.stable;
    nvidiaPackages.beta = selfnv.nvidiaPackages.stable;
    nvidia_x11 = selfnv.nvidiaPackages.stable;
  });
}
