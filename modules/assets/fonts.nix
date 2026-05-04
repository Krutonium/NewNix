{ ... }:
{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    let
      fontFiles = pkgs.fetchzip {
        url = "https://gitea.krutonium.ca/Krutonium/NixOS_Files/raw/branch/master/Fonts.zip";
        sha256 = "sha256-DHanWRSHKF79+f+smES52qgDFBSJOGn5MLFX12FIQOQ=";
        stripRoot = false;
      };
      fonts = pkgs.stdenv.mkDerivation {
        name = "Additional Fonts";
        src = fontFiles;
        buildCommand = ''
          mkdir -p $out/share/fonts
          cp -R $src $out/share/fonts/opentype/
        '';
      };
    in
    {
      fonts.packages = [
        fonts
        pkgs.rPackages.fontawesome
      ];
    };
}