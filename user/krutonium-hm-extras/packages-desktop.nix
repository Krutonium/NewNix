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

  #GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb obs



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

  # Run Idea and Rider using steam-run to fix plugins not working.
  #ideaScript = pkgs.writeShellScriptBin "idea-ultimate"
  #  ''
  #    ${pkgs.steam-run}/bin/steam-run ${pkgs.jetbrains.idea-ultimate}/bin/idea-ultimate
  #  '';
  #idea = pkgs.unstable.jetbrains.idea-ultimate.overrideAttrs
  #  (oldAttrs: { meta.priority = 10; });

  #yuzu = pkgs.yuzu-ea.overrideAttrs (oldAttrs: { meta.priority = 10; });
  #riderScript = pkgs.writeShellScriptBin "rider"
  #  ''
  #    ${pkgs.steam-run}/bin/steam-run ${pkgs.jetbrains.rider}/bin/rider
  #  '';
  #rider = pkgs.unstable.jetbrains.rider.overrideAttrs (oldAttrs: { meta.priority = 10; });
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
  #home.file.".net".source = dotnetCombined;
  home.file.".msbuild".source = pkgs.msbuild;

  home.packages = [
    # Browser
    #pkgs.firefox-wayland
    #pkgs.tor-browser-bundle-bin

    pkgs.qpwgraph
    
    #KDE Stuff
    #pkgs.yakuake
    #pkgs.tokodon

    # Gnome Stuff
    pkgs.gnome.dconf-editor
    pkgs.xwaylandvideobridge
    # Development
    openjdk8-low
    pkgs.openjdk17
    #pkgs.github-desktop Broken 23.05 OpenSSL_1_1 #TODO REPLACE OR FIX
    pkgs.hub
    pkgs.mono
    pkgs.ghc
    #idea
    #ideaScript  
    #(pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider [ "14839" "17718" "13882" ])
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider [ "github-copilot" ])
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea-ultimate [ "github-copilot" ])

    #rider
    #riderScript

    pkgs.vscode
    pkgs.gitkraken
    dotnetCombined
    #pkgs.dotnetCorePackages.sdk_6_0
    pkgs.dotnetPackages.StyleCopMSBuild
    pkgs.notepad-next
    #pkgs.msbuild
    #pkgs.dotnet-sdk
    pkgs.godot_4
    #pkgs.godot-export-templates

    # Wine
    pkgs.wineWowPackages.full
    pkgs.winetricks

    # Keyboard Stuff
    pkgs.unzip
    pkgs.qmk
    pkgs.arduino
    #pkgs.gcc11
    #pkgs.pkgsCross.avr.buildPackages.gcc
    #pkgs.avrdude
    #pkgs.gcc-arm-embedded
    #pkgs.gnumake
    pkgs.git
    #pkgs.python39Full

    # Media
    pkgs.vlc
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
    pkgs.catimg #for neofetch
    pkgs.nmap
    pkgs.gparted
    pkgs.ffmpeg-full
    pkgs.openrgb
    pkgs.calibre
    #pkgs.nixpkgs-review #moved to common
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
    #pkgs.sapling Not currently building
    pkgs.powerline-fonts
    pkgs.unzip
    pkgs.yt-dlp
    pkgs.matrix-synapse-tools.synadm
    pkgs.trash-cli
    pkgs.nvtop
    pkgs.comma

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
    # shipwright


    #pkgs.unstable.runescape #doesn't currently build
    pkgs.gamescope
    pkgs.jstest-gtk
    pkgs.prismlauncher
    pkgs.protonup
    pkgs.goverlay
    pkgs.dolphin-emu-beta
    pkgs.higan
    pkgs.heroic
    pkgs.cemu
    pkgs.citra
    pkgs.steam-run
    #pkgs.yuzu-ea
    #yuzu
    pkgs.ryujinx
    pkgs.monado

    # File Sync
    pkgs.dropbox
    #pkgs.megasync
    pkgs.nextcloud-client
    #pkgs.transmission-remote-gtk
    pkgs.deluge
    #pkgs.seafile-client

    # Communications
    pkgs.tdesktop
    #pkgs.element-desktop
    pkgs.fractal-next
    pkgs.srain
    pkgs.discord
    #pkgs.unstable.vesktop
    pkgs.wormhole-rs

    #AI Stuff I find interesting
    #pkgs.unstable.mods
    #pkgs.glow
  ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.unstable.obs-studio-plugins; [
      obs-teleport
    ];
    package = pkgs.unstable.obs-studio;
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
