{
  pkgs,
  ...
}:
let
  dotnetCombined =
    (
      with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_6_0
        sdk_8_0
        sdk_9_0
      ]
    ).overrideAttrs
      (
        _fineAttrs: previousAttrs: {
          postBuild =
            (previousAttrs.postBuild or '''')
            + ''
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
        }
      );
  #rider = (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider [ "github-copilot" ]);
  #idea = (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rust-rover [ "github-copilot" ]);
  bottles = (pkgs.bottles.override { removeWarningPopup = true; });

in
{
  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetCombined}";
  };

  home.packages = [
    # Desktop Environment
    pkgs.dconf-editor

    # Development Tools & IDEs
    dotnetCombined
    pkgs.godot_4-mono
    pkgs.jetbrains.rider
    pkgs.jetbrains.idea-ultimate
    # idea
    # rider

    # Wine & Windows Compatibility
    pkgs.winetricks
    pkgs.wineWow64Packages.full
    bottles

    # Hardware & System Tools
    pkgs.openrgb

    # Media & Entertainment
    pkgs.ffmpeg-full
    pkgs.spotify
    pkgs.vlc
    pkgs.youtube-music

    # Audio Tools

    # System Utilities
    pkgs.htop
    pkgs.fastfetch


    # Terminal & Shell Tools
    pkgs.babelfish
    pkgs.comma
    pkgs.fish
    pkgs.mcrcon
    pkgs.nvtopPackages.full
    pkgs.powerline-fonts
    pkgs.trash-cli
    pkgs.unzip
    pkgs.yt-dlp

    # Gaming
    # shipwright
    pkgs.shipwright
    pkgs._2ship2harkinian
    pkgs.appimage-run
    pkgs.goverlay
    pkgs.jstest-gtk
    pkgs.unstable.openrct2
    pkgs.prismlauncher
    pkgs.steam-run
    pkgs.nexusmods-app


    # File Sync & Downloads
    pkgs.deluge
    pkgs.nextcloud-client

    # Communication
    pkgs.fractal
    pkgs.srain
    pkgs.tdesktop
    pkgs.vesktop
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
}
