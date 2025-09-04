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
    buildInputs = [ ];
    buildCommand = ''
      mkdir -p $out/share/fonts
      cp -R $src $out/share/fonts/opentype/
    '';
  };
in
{
  # This is a patch specifically for Steam/Unity Games
  #fonts.fontDir.enable = true;
  # Link /run/current-system/sw/share/fonts to /etc/share/fonts
  #environment.etc."steamfonts" = {
  #  source = "/run/current-system/sw/share/X11/fonts/";
  #  target = "/share/fonts";
  #};

  fonts.packages = [
    fonts
    pkgs.rPackages.fontawesome
  ];
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
  environment.systemPackages = [
    pkgs.zed-editor
    pkgs.xorg.xf86inputmouse
    pkgs.rPackages.fontawesome
    pkgs.nano # Editor
    pkgs.git
    pkgs.tldr # Replace man
    pkgs.screen
    pkgs.tmux
    pkgs.file
    pkgs.wget
    pkgs.sshfs
    pkgs.usbutils
    pkgs.ripgrep
    pkgs.btop
    pkgs.killall
    pkgs.nix-index
    pkgs.appimage-run
    pkgs.unison
    pkgs.p7zip
    pkgs.pciutils
    pkgs.android-tools
    pkgs.nixfmt-rfc-style
    pkgs.btrfs-progs
    pkgs.cifs-utils
    pkgs.nixpkgs-review
    pkgs.unrar
    pkgs.ncurses
    pkgs.lm_sensors
    pkgs.wl-clipboard
    pkgs.sops
    pkgs.cachix
  ];

}
