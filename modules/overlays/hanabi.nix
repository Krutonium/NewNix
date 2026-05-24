{ inputs, ... }:
{
  flake.overlays.hanabi = final: prev: {
    gnome-shell-extension-hanabi = final.stdenv.mkDerivation {
      pname = "gnome-shell-extension-hanabi";
      version = "unstable-2025-05-23";

      src = final.fetchFromGitHub {
        owner = "jeffshee";
        repo = "gnome-ext-hanabi";
        rev = "854f3a93665e9d09edb3f944a8bce8d368a2e17f";
        hash = "sha256-+BrCMh6hDGNDVsReNoPzG3kNpnstjj0Cwdo/r2QIEkQ=";
      };

      nativeBuildInputs = with final; [
        meson
        ninja
        pkg-config
        glib
        gettext
      ];

      postPatch = ''
        substituteInPlace build-aux/meson-postinstall.sh \
          --replace-fail 'glib-compile-schemas' 'true'
          chmod +x build-aux/meson-postinstall.sh
      '';

      passthru = {
        extensionUuid = "hanabi-extension@jeffshee.github.io";
      };

      meta = with final.lib; {
        description = "Live wallpaper (video wallpaper) for GNOME Shell";
        homepage = "https://github.com/jeffshee/gnome-ext-hanabi";
        license = licenses.gpl3Plus;
        platforms = platforms.linux;
      };
    };
  };
}
