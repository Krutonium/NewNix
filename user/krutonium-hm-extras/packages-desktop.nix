{ config, pkgs, lib, makeDestopItem, fetchurl, ... }:
let
  downloadedNdi = builtins.fetchurl {
    url = https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v5_Linux.tar.gz;
    sha256 = "sha256:0lsiw523sqr6ydwxnikyijayfi55q5mzvh1zi216swvj5kfbxl00";
  };
  OOTROM = builtins.fetchurl {
    url = https://archive.org/download/ship-of-harkinian/ZELOOTD.zip/PAL%20GC.z64;
    sha256 = "sha256:1lim6has47jjhh1wgmfxpwawc5s22g245wp53gczihxa4wypk27p";
    name = "PAL_GC.z64";
  };
  openjdk8-low = pkgs.openjdk8.overrideAttrs (oldAttrs: { meta.priority = 10; });


  dotnetCombined = (with pkgs.dotnetCorePackages; combinePackages [ sdk_6_0 sdk_7_0 sdk_8_0 ]).overrideAttrs (fineAttrs: previousAttrs: {
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
  home.file.".msbuild".source = pkgs.msbuild;

  home.packages = [
    # Gnome Stuff
    pkgs.gnome.dconf-editor
    pkgs.xwaylandvideobridge
    # Development
    openjdk8-low
    pkgs.gh
    pkgs.openjdk17
    pkgs.hub
    pkgs.mono
    pkgs.ghc

    (pkgs.unstable.jetbrains.plugins.addPlugins pkgs.unstable.jetbrains.rider [ "github-copilot" ])
    (pkgs.unstable.jetbrains.plugins.addPlugins pkgs.unstable.jetbrains.idea-ultimate [ "github-copilot" ])
    pkgs.unityhub
    pkgs.nixd
    pkgs.nil

    #rider
    #riderScript
    pkgs.gitkraken
    dotnetCombined
    pkgs.dotnetPackages.StyleCopMSBuild
    pkgs.notepad-next
    # I desperately want godot with C# support guys.
    pkgs.godot_4

    # Wine
    pkgs.wineWowPackages.full
    pkgs.winetricks

    # Keyboard Stuff
    pkgs.unzip
    pkgs.qmk
    pkgs.arduino
    pkgs.git

    # Media
    pkgs.vlc
    pkgs.mpv
    pkgs.spotify
    pkgs.youtube-music
    pkgs.plexamp
    pkgs.plex-media-player

    # Audio Filtering
    pkgs.easyeffects
    pkgs.gnomeExtensions.easyeffects-preset-selector

    # Random Stuff
    pkgs.htop
    pkgs.neofetch
    pkgs.nmap
    pkgs.gparted
    pkgs.ffmpeg-full
    pkgs.openrgb
    # pkgs.calibre OH MY GOD YOU'RE AWFUL JESUS CHRIST
    pkgs.libreoffice
    pkgs.mate.engrampa
    pkgs.fzf
    pkgs.fsearch
    pkgs.sunshine

    # Terminal
    pkgs.nixpkgs-review
    pkgs.fish
    pkgs.oh-my-fish
    pkgs.babelfish
    pkgs.thefuck
    pkgs.powerline-fonts
    pkgs.unzip
    pkgs.yt-dlp
    pkgs.matrix-synapse-tools.synadm
    pkgs.trash-cli
    pkgs.nvtopPackages.full
    pkgs.comma
    pkgs.mcrcon

    # Wine/Windows Shit
    pkgs.lutris
    pkgs.bottles
    pkgs.pcem
    pkgs.looking-glass-client
    # Gaming
    # Steam is already installed at the system level because it has special requirements
    pkgs.unstable.openrct2
    pkgs.mesa-demos
    pkgs.parsec-bin
    pkgs.appimage-run
    pkgs.gamescope
    pkgs.jstest-gtk
    pkgs.prismlauncher
    pkgs.protonup
    pkgs.goverlay
    pkgs.dolphin-emu-beta
    pkgs.higan
    pkgs.heroic
    pkgs.cemu
    pkgs.steam-run
    pkgs.ryujinx
    pkgs.monado
    pkgs.unstable.openttd


    # File Sync
    pkgs.nextcloud-client
    pkgs.deluge

    # Communications
    pkgs.tdesktop
    pkgs.master.fractal
    pkgs.srain
    pkgs.vesktop
    pkgs.wormhole-rs
  ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.master.obs-studio-plugins; [
      #obs-teleport
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
    enableSessionWide = true;
    package = pkgs.mangohud;
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
}
