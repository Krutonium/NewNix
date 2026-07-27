{ self, inputs, ... }:
{
  flake.homeModules.packages-desktop =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    let
      bottles = (pkgs.bottles.override { removeWarningPopup = true; });
      hytaleWrapped = pkgs.symlinkJoin {
        name = "hytale";
        paths = [ pkgs.hytale-launcher ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hytale-launcher \
            --set SDL_VIDEODRIVER x11 \
        '';
        # This fixes OBS-Gamecapture by forcing the game to run in x11 mode instead of Wayland
      };

      telegramPatched =
        let
          version = "dev-unstable";

          src = pkgs.fetchFromGitHub {
            owner = "telegramdesktop";
            repo = "tdesktop";
            rev = "v7.0.2";
            hash = "sha256-G/A5J2m1sXHD50zDmMD9ehnorAGRjnQ+YGMv6DEiJcQ=";
            fetchSubmodules = true;
          };
          unwrapped = pkgs.unstable.telegram-desktop.unwrapped.overrideAttrs (oldAttrs: {
            inherit version src;
            patches = (oldAttrs.patches or [ ]) ++ [
              ./patches/telegram/0001-Disable-advertisements.patch
              ./patches/telegram/0002-Disable-advertisements.patch
              ./patches/telegram/0003-Disable-advertisements.patch
              ./patches/telegram/0004-Disable-saving-restrictions.patch
            ];
          });
        in
        pkgs.telegram-desktop.overrideAttrs (_: {
          unwrapped = unwrapped;
        });

    in
    {
      config = lib.mkIf (osConfig.services.desktopManager.gnome.enable == true) {
        home.packages = [
          # Developemnt
          pkgs.jetbrains.rider
          pkgs.jetbrains.idea

          # Games
          bottles
          hytaleWrapped
          pkgs.dolphin-emu
          pkgs.shipwright
          pkgs._2ship2harkinian
          pkgs.appimage-run
          pkgs.unstable.openrct2
          pkgs.prismlauncher
          pkgs.steam-run
          pkgs.sgdboop
          pkgs.dusklight

          # Media
          pkgs.ffmpeg-full
          pkgs.vlc
          #pkgs.deluge
          pkgs.nextcloud-client

          # Utilities
          pkgs.btop-cuda
          pkgs.hyfetch

          # Shell
          pkgs.nvtopPackages.full
          pkgs.powerline-fonts
          #pkgs.trash-cli
          pkgs.unzip
          pkgs.yt-dlp
          pkgs.atuin
          pkgs.unstable.ollama
          pkgs.opencode

          # Commuications
          pkgs.fluffychat
          telegramPatched
          pkgs.signal-desktop
          pkgs.vesktop
        ];

        programs = {
          obs-studio = {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [
              obs-multi-rtmp
              obs-vkcapture
              obs-backgroundremoval
            ];
            package = pkgs.obs-studio;
          };
          mangohud = {
            enable = true;
            enableSessionWide = false;
          };
          nix-index = {
            enable = true;
            enableFishIntegration = true;
          };
        };
      };
    };
}
