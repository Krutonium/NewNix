{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  dotnetCombined = (
    with pkgs.dotnetCorePackages;
    combinePackages [
      dotnet_8.sdk
      dotnet_9.sdk
      dotnet_10.sdk
    ]
  );
  commonPlugins = [ "nix-idea" ];

  #rider = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider commonPlugins;
  #idea = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea commonPlugins;
  #rider = (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider ["github-copilot" "nix-idea"]);
  #idea = (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea ["github-copilot" "nix-idea"]);
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
        ];
      });
    in
    pkgs.telegram-desktop.overrideAttrs (_: {
      unwrapped = unwrapped;
    });
in
{
  imports = [
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetCombined}";
  };
  home.packages = [
    # Desktop Environment
    pkgs.dconf-editor

    # Development Tools & IDEs
    dotnetCombined
    pkgs.mono
    #pkgs.godot_4-mono
    #idea
    #rider
    pkgs.jetbrains.rider
    pkgs.jetbrains.idea
    pkgs.nixd
    #pkgs.ocl-icd
    #pkgs.clinfo
    # idea
    # rider

    # Wine & Windows Compatibility
    bottles
    pkgs.wineWow64Packages.waylandFull # Wine with Wayland Compat
    pkgs.prefixer

    # Hardware & System Tools
    #pkgs.openrgb

    # Media & Entertainment
    pkgs.ffmpeg-full
    #pkgs.spotify
    pkgs.vlc
    pkgs.plex-desktop

    # Audio Tools

    # System Utilities
    pkgs.htop
    #pkgs.neohtop
    pkgs.fastfetch
    #pkgs.unstable.rustdesk-flutter
    #pkgs.kdePackages.kleopatra
    #pkgs.remmina

    # Terminal & Shell Tools
    pkgs.babelfish
    pkgs.comma
    pkgs.fish
    pkgs.mcrcon
    pkgs.nvtopPackages.full
    pkgs.powerline-fonts
    #pkgs.trash-cli
    pkgs.unzip
    pkgs.yt-dlp

    # Gaming
    # shipwright
    pkgs.protonplus
    hytaleWrapped
    pkgs.shipwright
    pkgs._2ship2harkinian
    pkgs.appimage-run
    pkgs.goverlay
    #pkgs.jstest-gtk
    pkgs.openrct2
    #pkgs.samrewritten #Steam Achievement Manager
    #pkgs.unstable.zelda64recomp
    pkgs.prismlauncher
    pkgs.steam-run
    pkgs.sgdboop

    #pkgs.dolphin-emu
    #pkgs.pcsx2
    #pkgs.shadps4
    #pkgs.cemu

    # File Sync & Downloads
    pkgs.deluge
    pkgs.nextcloud-client

    # Communication
    #pkgs.fractal
    pkgs.fluffychat
    #pkgs.srain
    #pkgs.ayugram-desktop
    telegramPatched
    #(pkgs.discord.override {
    #withOpenASAR = true;
    #withVencord = true;
    #withMoonlight = true;
    #})
    pkgs.unstable.vesktop
    pkgs.teamspeak6-client
    #pkgs.handbrake
    #pkgs.unstable.teamspeak6-client

    # Hashcat
    #pkgs.hashcat

    #pkgs.gpu-screen-recorder-gtk
  ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-multi-rtmp
      obs-vkcapture
      obs-backgroundremoval
    ];
    package = pkgs.obs-studio;
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
    package = pkgs.mangohud;
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
}
