self: super: {
  intel-media-sdk = super.intel-media-sdk.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [ "-DCMAKE_CXX_STANDARD=17" ];
    NIX_CFLAGS_COMPILE = "-std=c++17";
  });
}
