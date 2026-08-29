{ ... }:
{
  flake.homeModules.packages-desktop =
    {
      osConfig,
      lib,
      pkgs,
      mv,
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
          unwrapped = mv.tip.telegram-desktop.unwrapped.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or [ ]) ++ [
              ./patches/telegram/0001-Disable-advertisements.patch
              ./patches/telegram/0002-Disable-advertisements.patch
              ./patches/telegram/0003-Disable-advertisements.patch
              ./patches/telegram/0004-Disable-saving-restrictions.patch
            ];
          });
        in
        mv.tip.telegram-desktop.overrideAttrs (_: {
          unwrapped = unwrapped;
        });
    in
    {
      config = lib.mkIf (osConfig.services.desktopManager.gnome.enable == true) {
        home.packages = [
          # Games
          mv.tip.eden
          bottles
          hytaleWrapped
          pkgs.dolphin-emu
          pkgs.shipwright
          pkgs._2ship2harkinian
          pkgs.appimage-run
          mv.tip.openrct2
          pkgs.prismlauncher
          pkgs.steam-run
          mv.tip.sgdboop
          pkgs.dusklight
          pkgs.satisfactorymodmanager

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
          #mv.tip.ollama
          mv.tip.opencode

          # Commuications
          pkgs.fluffychat
          telegramPatched
          pkgs.signal-desktop
          #pkgs.vesktop
          mv.tip.legcord
        ];

        programs = {
          obs-studio = {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [
              obs-multi-rtmp
              obs-vkcapture
              obs-backgroundremoval
              #distroav #NDI! It works!
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
