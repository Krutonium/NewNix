{ inputs, ... }:
{
  flake.homeModules.packages-desktop =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    let
      dotnet = (
        with pkgs.dotnetCorePackages;
        combinePackages [
          dotnet_8.sdk
          dotnet_9.sdk
          dotnet_10.sdk
        ]
      );
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
            rev = "ae7ab838f450b73b30ade03a87cfdb6ff4b68bd3";
            hash = "sha256-nN6a/TPMGmB59HS7uYvNuLVAXjn2XbJWuAqlPft0jww=";
            fetchSubmodules = true;
          };
          unwrapped = pkgs.telegram-desktop.unwrapped.overrideAttrs (oldAttrs: {
            inherit version src;
            patches = (oldAttrs.patches or [ ]) ++ [
              ./patches/telegram/0001-Disable-advertisements.patch
              ./patches/telegram/0002-Disable-advertisements.patch
              ./patches/telegram/0003-Disable-advertisements.patch
            ];
          });
        in
        pkgs.telegram-desktop.overrideAttrs (_: {
          unwrapped = unwrapped;
        });
    in
    {
      config = lib.mkIf (osConfig.services.displayManager.gdm.enable == true) {
        home.sessionVariables = {
          DOTNET_ROOT = "${dotnet}/share/dotnet";
        };
        home.packages = [
          # Developemnt
          dotnet
          #pkgs.jetbrains.rider
          #pkgs.jetbrains.idea

          # Games
          bottles
          hytaleWrapped
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
          pkgs.neofetch

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
          zed-editor = {
            enable = true;
            package = pkgs.unstable.zed-editor;
            extensions = [
              "nix"
              "toml"
              "csharp"
            ];
            userSettings = {
              "languages" = {
                "Nix" = {
                  "soft_wrap" = "editor_width";
                  "tab_size" = 2;
                  "language_servers" = [
                    "${pkgs.nixd}/bin/nixd"
                  ];
                  "formatter" = {
                    "external" = {
                      "command" = "nixfmt";
                    };
                  };
                };
              };
              "base_keymap" = "VSCode";
              "session" = {
                "trust_all_worktrees" = true;
              };
              "ui_font_size" = 16.0;
              "buffer_font_size" = 17.333333333333332;
              "features" = {
                "edit_prediction_provider" = "none";
              };
              "assistant" = {
                "enabled" = false;
              };
              "agent" = {
                "enabled" = false;
              };
            };
            userKeymaps = {
              "context" = "Editor";
              "bindings" = {
                "ctrl-k ctrl-f" = "editor::Format";
              };
            };
          };
        };
      };
    };
}
