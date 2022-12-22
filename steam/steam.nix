{ config, pkgs, lib, pkgs-unstable, ... }:
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

    buildInputs = with pkgs-unstable; [
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

  monado = (pkgs-unstable.monado.overrideAttrs (old: {
    src = pkgs-unstable.fetchFromGitLab {
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

  #########
  # STEAM #
  #########

  steam_common = {
    dev = true; # required for vulkan
    net = true;
    tmp = true;
    xdg = prefs.steam.vr_integration;
    binds =
      [
        # you can run a proton game with the TARGET: explorer.exe
        # to verify if the proton is not accessing the wrong files
        {
          from = "~/bwrap/steam";
          to = "~/";
        }
      ] ++ prefs.bwrap_binds.game;
    custom_config = [
      # FIXES: Proton games breaking on wayland
      "--unsetenv XDG_SESSION_TYPE"
      "--unsetenv CLUTTER_BACKEND"
      "--unsetenv QT_QPA_PLATFORM"
      "--unsetenv SDL_VIDEODRIVER"
      "--unsetenv SDL_AUDIODRIVER"
      "--unsetenv NIXOS_OZONE_WL"
      "--setenv STEAM_EXTRA_COMPAT_TOOLS_PATHS ${
              pkgs.stdenv.mkDerivation rec {
                pname = "proton-ge-custom";
                version = "GE-Proton7-35";

                src = pkgs.fetchurl {
                  url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
                  sha256 = "sha256-ZMdsn5mShBpAyqlkSH1xWs076UTE952AZsJL8luZLoc=";
                };

                buildCommand = ''
                  mkdir -p $out
                  tar -C $out --strip=1 -x -f $src
                '';
              }
            }"
      "--setenv VR_OVERRIDE ${open_composite}"
      "--setenv XR_RUNTIME_JSON ${monado}/share/openxr/1/openxr_monado.json"
      "--setenv PRESSURE_VESSEL_FILESYSTEMS_RW $XDG_RUNTIME_DIR/monado_comp_ipc"
    ];
  };
in
{
  config = mkIf (cfg.steam == true) {
    config = mkIf (cfg.steam == true) {
      environment.systemPackages = with pkgs;[
        monado
        openhmd

        (lib.bwrapIt
          ({
            name = "steam-run";
            package = steam-run;
            args = "$@";
          } // steam_common))

        (lib.bwrapIt
          ({
            name = "steam";
            args = "-console";
            package = steam.override {
              runtimeOnly = true;
              extraPkgs = pkgs: [ ];
              extraLibraries = pkgs:
                [ elfutils ] ++
                  # Fixes: dxvk::DxvkError
                  (with config.hardware.opengl; if pkgs.hostPlatform.is64bit
                  then [ package ] ++ extraPackages
                  else [ package32 ] ++ extraPackages32);
            };
          } // steam_common))

      ] ++ optionals prefs.steam.vr_integration [
        (lib.bwrapIt {
          name = "steam-vr";
          package = monado;
          exec = "bin/monado-service";
          args = "$@";
          dev = true; # required for vulkan
          tmp = true;
          xdg = true;
          binds = [ ];
        })
      ];

      services.udev.packages = [ rift_s_udev ];
    };
  };
}
