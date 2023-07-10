########################
# VR: MONADO + STEAMVR #
########################

# To run monado + SteamVR you need to use steam-run to patch the SteamVR
# drivers:
# steam-run ./.local/share/Steam/steamapps/common/SteamVR/bin/vrpathreg.sh adddriver ${monado}/share/steamvr-monado
#
# SteamVR needs CAP_SYS_NICE+ep to be able to work properly:
# sudo setcap 'cap_sys_nice+ep' /home/shiryel/bwrap/steam/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
#
# Check with:
# steam-run getcap ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
#
# Finaly, enable the monado-service(?) with steam-vr and try run a game
# You can check the logs with:
# steam-run cat ~/.steam/steam/logs/vrserver.txt
#
# You can unset the CAP_SYS_NICE with:
# sudo setcap -r /home/shiryel/bwrap/steam/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
#


# Based on https://github.com/shiryel/nixos-dotfiles/blob/master/system/modules/steam.nix


{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.steam;
  open_composite = pkgs.stdenv.mkDerivation rec {
    pname = "open-composite";
    version = "git";
    src = pkgs.fetchFromGitLab {
      owner = "znixian";
      repo = "OpenOVR";
      rev = "c5256a117f82c04e3f74cc8b3e2eb357f1425270";
      sha256 = "sha256-0Es5FuEwu0L43VOYGdNBfxuBehlNx35ymjBUOG/pKLU=";
      fetchSubmodules = true;
    };

    # disable all warnings (they become errors)
    NIX_CFLAGS_COMPILE = "-Wno-error -w";

    nativeBuildInputs = with pkgs;[
      cmake
    ];

    buildInputs = with pkgs.unstable; [
      vulkan-loader
      vulkan-headers
      libGLU
      python39
      xorg.libX11
    ];

    enableParallelBuilding = true;

    installPhase = ''
      cp -r . $out
    '';
  };

  patch-vr = pkgs.writeShellScriptBin "patch-vr" ''
    steam-run ./.local/share/Steam/steamapps/common/SteamVR/bin/vrpathreg.sh adddriver ${monado}/share/steamvr-monado
    '';

  monado = (pkgs.unstable.monado.overrideAttrs (old: {
    src = pkgs.unstable.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "monado";
      repo = "monado";
      rev = "9293c628d78ba595918b6b21460fc1df2fbd6f45";
      sha256 = "sha256-oDYyrO45TBl8sTcjk6okMJ5vpqGA08h0XJTcf7grnfo=";
    };
  }));

  rift_s_udev = pkgs.writeTextFile {
    name = "moonlander-udev-rules";
    text = ''
      # Skip if a remove
      ACTION=="remove", GOTO="xrhardware_end"

      # Oculus Rift S - USB
      ATTRS{idVendor}=="2833", ATTRS{idProduct}=="0051", TAG+="uaccess", ENV{ID_xrhardware}="1"

      # Exit if we didn't find one
      ENV{ID_xrhardware}!="1", GOTO="xrhardware_end"

      # XR devices with serial ports aren't modems, modem-manager
      ENV{ID_xrhardware_USBSERIAL_NAME}!="", SUBSYSTEM=="usb", ENV{ID_MM_DEVICE_IGNORE}="1"

      # Make friendly symlinks for XR USB-Serial devices.
      ENV{ID_xrhardware_USBSERIAL_NAME}!="", SUBSYSTEM=="tty", SYMLINK+="ttyUSB.$env{ID_xrhardware_USBSERIAL_NAME}"

      LABEL="xrhardware_end"
    '';
    destination = "/lib/udev/rules.d/70-xrhardware.rules";
  };
in
{
  config = mkIf (cfg.steam == true) {
    environment.systemPackages = with pkgs;[
      monado
      openhmd
      steam-run
      (steam.override {
        extraPkgs = pkgs: [ glxinfo jre8 ];
      }).run
      patch-vr
    ];
    #services.udev.packages = [ rift_s_udev ];
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    services.xserver.config = ''
      Option "AllowHMD" "yes"
    '';
    #services.xserver.deviceSection = ''
    #  Identifier             "Device0"
    #  Driver                 "nvidia"#

    #Option "AllowHMD"      "yes"
    #'';
  };
}
