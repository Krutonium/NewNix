{ config, pkgs, ... }:
let
  fontFiles = pkgs.fetchzip {
    url = "https://gitea.krutonium.ca/Krutonium/NixOS_Files/raw/branch/master/Fonts.zip";
    sha256 = "sha256-Wd34O33F2RKgw0TUjtH1iAj83/7LxWjN2vOAIl6CgRY=";
    stripRoot = false;
  };
  fonts = pkgs.stdenv.mkDerivation {
    name = "Additional Fonts";
    src = fontFiles;
    buildInputs = [ ];
    buildCommand =
      ''
        mkdir -p $out/share/fonts
        cp -R $src $out/share/fonts/opentype/
      '';
  };
in
{
  fonts.packages = [ fonts pkgs.rPackages.fontawesome ];
  environment.systemPackages = [
    pkgs.xorg.xf86inputmouse
    pkgs.rPackages.fontawesome
    pkgs.nano #Editor
    pkgs.git
    pkgs.tldr #Replace man
    pkgs.screen
    pkgs.colmena
    pkgs.tmux
    pkgs.file
    pkgs.wget
    pkgs.sshfs
    pkgs.usbutils
    pkgs.pinentry-gnome
    pkgs.ripgrep
    pkgs.btop
    pkgs.killall
    pkgs.nix-index
    pkgs.appimage-run
    pkgs.unison
    pkgs.p7zip
    pkgs.pciutils
    pkgs.android-tools
    pkgs.nixpkgs-fmt
    pkgs.btrfs-progs
    pkgs.cifs-utils
    pkgs.nixpkgs-review
    pkgs.unrar
    pkgs.ncurses
    #pkgs.nixd
    pkgs.lm_sensors
    pkgs.wl-clipboard
  ];

}
