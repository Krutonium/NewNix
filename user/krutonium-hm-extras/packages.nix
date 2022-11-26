{ config, pkgs, pkgs-unstable, lib, makeDestopItem, ... }:
let

in
{
  nixpkgs.overlays = [
    (self: super: {
      godot-mono = with super;
        let
          arch = "64";
          version = "3.5";
          releaseName = "stable";
          subdir = "";
          pkg = stdenv.mkDerivation {
            name = "godot-mono-unwrapped";
            buildInputs = [ unzip ];
            unpackPhase = "unzip $src";
            version = version;
            src = fetchurl {
              url = "https://downloads.tuxfamily.org/godotengine/${version}${subdir}/mono/Godot_v${version}-${releaseName}_mono_x11_${arch}.zip";
              sha256 = "sha256-rQyhvfgiqa81Pxf4Nz2/0yhi5Vyp+CMNx1K3hAZWuJ4=";
            };
            installPhase = ''
              cp -r . $out
            '';
          };
        in
        buildFHSUserEnv {
          name = "godot-mono";
          targetPkgs = pkgs: (with pkgs;
            [
              alsaLib
              dotnetCorePackages.sdk_5_0
              libGL
              libpulseaudio
              udev
              xorg.libX11
              xorg.libXcursor
              xorg.libXext
              xorg.libXi
              xorg.libXinerama
              xorg.libXrandr
              xorg.libXrender
              zlib
            ]);
          runScript = "${pkg.outPath}/Godot_v${version}-${releaseName}_mono_x11_${arch}/Godot_v${version}-${releaseName}_mono_x11.${arch}";
        };
    })
  ];
  nixpkgs.config.allowUnfreePredicate = (pkg: true);
  home.packages =
    let
      openjdk8-low = pkgs.openjdk8.overrideAttrs (oldAttrs: { meta.priority = 10; });
      dotnet = (with pkgs.dotnetCorePackages; combinePackages [ sdk_5_0 sdk_6_0 pkgs-unstable.dotnet-sdk_7 ]);

      # Run Idea and Rider using steam-run to fix plugins not working.
      ideaScript = pkgs.writeShellScriptBin "idea-ultimate"
        ''
          ${pkgs.steam-run}/bin/steam-run ${pkgs.jetbrains.idea-ultimate}/bin/idea-ultimate
        '';
      idea = pkgs.jetbrains.idea-ultimate.overrideAttrs (oldAttrs: { meta.priority = 10; });
      riderScript = pkgs.writeShellScriptBin "rider"
        ''
          ${pkgs.steam-run}/bin/steam-run ${pkgs.jetbrains.rider}/bin/rider
        '';
      rider = pkgs.jetbrains.rider.overrideAttrs (oldAttrs: { meta.priority = 10; });
    in
    [
      # Browser
      pkgs.firefox-wayland

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
      pkgs-unstable.gnomeExtensions.arcmenu

      # Development
      openjdk8-low
      pkgs.openjdk17
      pkgs.github-desktop
      pkgs.mono
      idea
      ideaScript
      rider
      riderScript
      pkgs.gitkraken
      dotnet
      pkgs.godot-mono
      pkgs.godot-export-templates


      # Wine
      pkgs-unstable.wineWowPackages.stable
      pkgs-unstable.wine-wayland
      pkgs-unstable.winetricks


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
      pkgs-unstable.obs-studio

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
      pkgs.openrgb
      #pkgs.calibre
      pkgs.nixpkgs-review
      pkgs.libreoffice
      pkgs.mate.engrampa

      # Terminal
      pkgs.fish
      pkgs.oh-my-fish
      pkgs.babelfish
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
      # Gaming
      # Steam is already installed at the system level because it has special requirements
      pkgs.openrct2
      pkgs.jstest-gtk
      pkgs.prismlauncher
      pkgs.protonup
      pkgs.mangohud
      pkgs.goverlay
      pkgs.dolphin-emu-beta
      pkgs-unstable.heroic
      pkgs.steam-run
      pkgs.yuzu-ea
      pkgs.monado

      # File Sync
      pkgs.dropbox
      #pkgs.nextcloud-client
      #pkgs.transmission-remote-gtk
      pkgs.deluge
      #pkgs.seafile-client

      # Communications
      pkgs-unstable.tdesktop
      pkgs.element-desktop
      pkgs.fractal
      pkgs.discord
    ];
}
