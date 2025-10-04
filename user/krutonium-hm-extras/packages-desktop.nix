{ pkgs
, lib
, osConfig
, ...
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

  #obs-studio = pkgs.obs-studio.overrideAttrs (old: {
  #  pname = "obs-studio-git";
  #  version = "13.1.0-custom";
  #  src = pkgs.fetchFromGitHub {
  #    owner = "obsproject";
  #    repo = "obs-studio";
  #    rev = "d3c5d2ce0b15bac7a502f5aef4b3b5ec72ee8e09";
  #    fetchSubmodules = true;
  #    sha256 = "sha256-z6BMgddmq3+IsVkt0a/FP+gShvGi1tI6qBbJlAcHgW8=";
  #  };
  #  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
  #    pkgs.extra-cmake-modules
  #  ];
  #});

  MajorasMask = builtins.fetchurl {
    url = "https://dl.krutonium.ca/mm.us.rev1.rom.z64";
    name = "mm.us.rev1.rom.z64"; # this sets the filename in the Nix store
    sha256 = "sha256:0arzwhxmxgyy6w56dgm5idlchp8zs6ia3yf02i2n0qp379dkdcgg";
  };

  rider = (pkgs.unstable.jetbrains.plugins.addPlugins pkgs.unstable.jetbrains.rider [ "github-copilot" ]);
  idea = (pkgs.unstable.jetbrains.plugins.addPlugins pkgs.unstable.jetbrains.idea-ultimate [ "github-copilot" ]);
  bottles = (pkgs.bottles.override { removeWarningPopup = true; });

in
{
  imports = [
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetCombined}";
    _MM_ROM = "${MajorasMask}";
  };
  home.packages = [
    # Desktop Environment
    pkgs.dconf-editor

    # Development Tools & IDEs
    dotnetCombined
    pkgs.godot_4-mono
    pkgs.unstable.jetbrains.rider
    pkgs.unstable.jetbrains.idea-ultimate
    # idea
    # rider

    # Wine & Windows Compatibility
    bottles

    # Hardware & System Tools
    pkgs.openrgb

    # Media & Entertainment
    pkgs.ffmpeg-full
    pkgs.spotify
    pkgs.vlc

    # Audio Tools

    # System Utilities
    pkgs.htop
    pkgs.fastfetch
    #pkgs.unstable.rustdesk-flutter
    pkgs.kdePackages.kleopatra

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
    pkgs.unstable.sgdboop

    pkgs.dolphin-emu
    pkgs.pcsx2
    pkgs.shadps4
    pkgs.cemu

    # File Sync & Downloads
    pkgs.deluge
    pkgs.nextcloud-client

    # Communication
    pkgs.fractal
    pkgs.srain
    pkgs.unstable.telegram-desktop
    #(pkgs.discord.override {
      #withOpenASAR = true;
      #withVencord = true;
      #withMoonlight = true;
    #})
    pkgs.unstable.vesktop


    # Hashcat
    (pkgs.unstable.hashcat.override { cudaSupport = true; })
  ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.unstable.obs-studio-plugins; [
      obs-multi-rtmp
      obs-vkcapture
      obs-backgroundremoval
    ];
    package =
      if osConfig.networking.hostName == "uGamingPC"
      then pkgs.unstable.obs-studio.override { cudaSupport = true; }
      else pkgs.unstable.obs-studio;

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
