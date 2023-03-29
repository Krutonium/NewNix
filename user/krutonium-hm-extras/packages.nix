{ config, pkgs, lib, makeDestopItem, fetchurl, ... }:
let
  ndi = builtins.fetchurl {
    url = https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v5_Linux.tar.gz;
    sha256 = "sha256:0lsiw523sqr6ydwxnikyijayfi55q5mzvh1zi216swvj5kfbxl00";
  };
in
{
  home.file.".config/NDI".source = ndi; # This ensures it's in the store.
  home.packages =
    let
      openjdk8-low = pkgs.openjdk8.overrideAttrs (oldAttrs: { meta.priority = 10; });
      dotnetCombined = with pkgs.dotnetCorePackages; combinePackages [ sdk_3_1 sdk_6_0 sdk_7_0 pkgs.msbuild ];

      # Run Idea and Rider using steam-run to fix plugins not working.
      ideaScript = pkgs.writeShellScriptBin "idea-ultimate"
        ''
          ${pkgs.steam-run}/bin/steam-run ${pkgs.unstable.jetbrains.idea-ultimate}/bin/idea-ultimate
        '';
      idea = pkgs.unstable.jetbrains.idea-ultimate.overrideAttrs
        (oldAttrs: { meta.priority = 10; });
      riderScript = pkgs.writeShellScriptBin "rider"
        ''
          ${pkgs.steam-run}/bin/steam-run ${pkgs.unstable.jetbrains.rider}/bin/rider
        '';
      rider = pkgs.unstable.jetbrains.rider.overrideAttrs (oldAttrs: { meta.priority = 10; });
    in
    [
      # Browser
      pkgs.firefox-wayland
      pkgs.tor-browser-bundle-bin

      # Gnome Stuff
      pkgs.gnome.gnome-tweaks
      pkgs.gnomeExtensions.dash-to-panel
      pkgs.arc-theme
      pkgs.sweet
      pkgs.whitesur-gtk-theme
      pkgs.whitesur-icon-theme
      pkgs.ubuntu_font_family
      pkgs.bibata-extra-cursors
      pkgs.gnomeExtensions.appindicator
      pkgs.gnome.dconf-editor
      pkgs.gnomeExtensions.arcmenu
      pkgs.gnomeExtensions.no-overview
      pkgs.gnomeExtensions.adjust-display-brightness

      # Development
      openjdk8-low
      pkgs.openjdk17
      pkgs.github-desktop
      pkgs.hub
      pkgs.mono
      idea
      ideaScript
      rider
      riderScript
      pkgs.vscode
      pkgs.gitkraken
      dotnetCombined
      pkgs.notepad-next
      #pkgs.msbuild
      #pkgs.dotnet-sdk
      #pkgs.godot-mono
      #pkgs.godot-export-templates


      # Wine
      pkgs.wineWowPackages.full
      pkgs.winetricks

      # Keyboard Stuff
      pkgs.unzip
      pkgs.qmk
      pkgs.qmk-udev-rules
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

      # Audio Filtering
      pkgs.easyeffects
      pkgs.gnomeExtensions.easyeffects-preset-selector

      # Random Stuff
      pkgs.htop
      pkgs.gimp
      pkgs.neofetch
      pkgs.catimg #for neofetch
      pkgs.nmap
      pkgs.gparted
      pkgs.ffmpeg-full
      pkgs.unstable.openrgb
      pkgs.calibre
      #pkgs.nixpkgs-review #moved to common
      pkgs.libreoffice
      pkgs.mate.engrampa
      pkgs.fzf

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
      pkgs.unstable.bottles
      pkgs.pcem
      # Gaming
      # Steam is already installed at the system level because it has special requirements
      pkgs.openrct2
      pkgs.mesa-demos

      # RetroArch
      pkgs.libretro.parallel-n64
      pkgs.libretro.snes9x
      (pkgs.retroarch.override {
        cores = [
          pkgs.libretro.snes9x
          pkgs.libretro.parallel-n64
        ];
      })

      #pkgs.unstable.runescape #doesn't currently build
      pkgs.gamescope
      pkgs.jstest-gtk
      pkgs.unstable.prismlauncher
      pkgs.protonup
      pkgs.goverlay
      pkgs.dolphin-emu-beta
      pkgs.unstable.heroic
      pkgs.unstable.cemu
      pkgs.unstable.citra
      pkgs.steam-run
      pkgs.yuzu-ea
      pkgs.monado

      # File Sync
      pkgs.dropbox
      #pkgs.megasync
      #pkgs.nextcloud-client
      #pkgs.transmission-remote-gtk
      pkgs.deluge
      #pkgs.seafile-client

      # Communications
      pkgs.unstable.tdesktop
      pkgs.element-desktop
      pkgs.fractal
      pkgs.srain
      pkgs.discord
      pkgs.ripcord
    ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
      obs-multi-rtmp
      obs-ndi
    ];
  };
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    package = pkgs.mangohud;
  };
}
