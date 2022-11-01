{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.nano #Editor
    pkgs.git
    pkgs.tldr #Replace man
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
    pkgs.deploy-cs
    pkgs.appimage-run
    pkgs.unison
    pkgs.p7zip
    pkgs.pciutils
    pkgs.android-tools
    pkgs.nixpkgs-fmt
    pkgs.btrfs-progs
  ];
}