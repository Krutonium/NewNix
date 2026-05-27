{ inputs, ... }:
{
  flake.overlays.openldap = final: prev: {
    openldap = prev.openldap.overrideAttrs {
      doCheck = !prev.stdenv.hostPlatform.isi686;
    };
  };
}
