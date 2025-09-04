self: super:
{
  zed = super.zed.overrideAttrs (old: rec {
    version = "unstable-$(builtins.substring 0 8 src.rev)";

    src = super.fetchFromGitHub {
      owner = "brimdata";
      repo = "zed";
      rev = "master";
      sha256 = lib.fakeSha256; # replace with real hash after first build
    };
    vendorHash = lib.fakeSha256; # will need updating after first build
  });
}
