{ config, pkgs, lib, makeDestopItem, fetchurl, ... }:
let
  OOTROM = builtins.fetchurl {
    url = "https://archive.org/download/ship-of-harkinian/ZELOOTD.zip/PAL%20GC.z64";
    sha256 = "sha256:1lim6has47jjhh1wgmfxpwawc5s22g245wp53gczihxa4wypk27p";
    name = "PAL_GC.z64";
  };
  openjdk8-low = pkgs.openjdk8.overrideAttrs (oldAttrs: { meta.priority = 10; });

  dotnetCombined = (with pkgs.dotnetCorePackages; combinePackages [ sdk_8_0 sdk_9_0 ]).overrideAttrs (fineAttrs: previousAttrs: {
    postBuild = (previousAttrs.postBuild or '''') + ''
       for i in $out/sdk/*
       do
         i=$(basename $i)
         length=$(printf "%s" "$i" | wc -c)
         substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
         i="$substring""00"
         mkdir -p $out/metadata/workloads/''${i/-*}
         touch $out/metadata/workloads/''${i/-*}/userlocal
      done
    '';
  });
  shipwright = pkgs.shipwright.override {
    oot = {
      enable = true;
      variant = "pal_gc";
      rom = OOTROM;
    };
  };
in
{
  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetCombined}";
  };

  home.packages = [
    # Desktop Environment
    pkgs.dconf-editor
    pkgs.xwaylandvideobridge

    # Development Tools & IDEs
    dotnetCombined
    pkgs.gh
    pkgs.ghc
    pkgs.gitkraken
    pkgs.godot_4-mono
    pkgs.hub
    (pkgs.master.jetbrains.plugins.addPlugins pkgs.master.jetbrains.idea-ultimate [ "github-copilot" "nixidea" ])
    (pkgs.master.jetbrains.plugins.addPlugins pkgs.master.jetbrains.rider [ "github-copilot" ])
    (pkgs.master.jetbrains.plugins.addPlugins pkgs.master.jetbrains.rust-rover [ "github-copilot" ])
    
    pkgs.mono
    pkgs.nil
    pkgs.nixd
    pkgs.notepad-next
    openjdk8-low
    pkgs.openjdk17
    pkgs.unityhub

    # Wine & Windows Compatibility
    pkgs.bottles
    pkgs.looking-glass-client
    pkgs.lutris
    pkgs.winetricks
    pkgs.wineWowPackages.full

    # Hardware & System Tools
    pkgs.arduino
    pkgs.git
    pkgs.gparted
    pkgs.openrgb
    pkgs.qmk

    # Media & Entertainment
    pkgs.ffmpeg-full
    pkgs.mpv
    pkgs.plex-media-player
    pkgs.plexamp
    pkgs.spotify
    pkgs.vlc
    pkgs.youtube-music

    # Audio Tools
    pkgs.easyeffects
    pkgs.gnomeExtensions.easyeffects-preset-selector

    # System Utilities
    pkgs.fsearch
    pkgs.fzf
    pkgs.htop
    pkgs.libreoffice
    pkgs.mate.engrampa
    pkgs.neofetch
    pkgs.nmap
    pkgs.sunshine

    # Terminal & Shell Tools
    pkgs.babelfish
    pkgs.comma
    pkgs.fish
    pkgs.matrix-synapse-tools.synadm
    pkgs.mcrcon
    pkgs.nixpkgs-review
    pkgs.nvtopPackages.full
    pkgs.oh-my-fish
    pkgs.powerline-fonts
    pkgs.streamlink
    pkgs.thefuck
    pkgs.trash-cli
    pkgs.unzip
    pkgs.yt-dlp

    # Gaming
    pkgs.appimage-run
    pkgs.cemu
    pkgs.dolphin-emu-beta
    pkgs.gamescope
    pkgs.goverlay
    pkgs.heroic
    pkgs.higan
    pkgs.jstest-gtk
    pkgs.mesa-demos
    pkgs.monado
    pkgs.unstable.openrct2
    #pkgs.unstable.openttd
    pkgs.parsec-bin
    pkgs.prismlauncher
    pkgs.protonup
    pkgs.ryujinx
    pkgs.steam-run

    # File Sync & Downloads
    pkgs.deluge
    pkgs.nextcloud-client

    # Communication
    pkgs.fractal
    pkgs.srain
    pkgs.tdesktop
    pkgs.vesktop
    pkgs.wormhole-rs
  ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.master.obs-studio-plugins; [
      obs-multi-rtmp
      obs-vkcapture
    ];
    package = pkgs.master.obs-studio;
  };
  xdg.desktopEntries = {
    "OBS" = {
      name = "OBS Studio X11";
      genericName = "Screen Recorder";
      exec = "env QT_QPA_PLATFORM=xcb obs";
      terminal = false;
      icon = "com.obsproject.Studio";
    };
    "discord" = {
      name = "Vesktop";
      genericName = "Discord";
      exec = "vesktop";
      terminal = false;
      icon = "vesktop";
    };
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
  programs.atuin = {
    enableFishIntegration = true;
    enable = true;
  };
}
