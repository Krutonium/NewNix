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
        dotnet_8.sdk
        dotnet_9.sdk
        dotnet_10.sdk
      ]
    );
  MajorasMask = builtins.fetchurl {
    url = "https://dl.krutonium.ca/mm.us.rev1.rom.z64";
    name = "mm.us.rev1.rom.z64"; # this sets the filename in the Nix store
    sha256 = "sha256:0arzwhxmxgyy6w56dgm5idlchp8zs6ia3yf02i2n0qp379dkdcgg";
  };

  commonPlugins = [ "nix-idea" ];

  #rider = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider commonPlugins;
  #idea = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea commonPlugins;
  #rider = (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider ["github-copilot" "nix-idea"]);
  #idea = (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea ["github-copilot" "nix-idea"]);
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
    pkgs.mono
    pkgs.godot_4-mono
    #idea
    #rider
    pkgs.jetbrains.rider
    pkgs.jetbrains.idea
    pkgs.ocl-icd
    pkgs.clinfo
    # idea
    # rider

    # Wine & Windows Compatibility
    bottles

    # Hardware & System Tools
    #pkgs.openrgb

    # Media & Entertainment
    pkgs.ffmpeg-full
    pkgs.spotify
    pkgs.vlc

    # Audio Tools

    # System Utilities
    pkgs.htop
    pkgs.neohtop
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
    pkgs.openrct2
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
    pkgs.unstable.ayugram-desktop
    #(pkgs.discord.override {
      #withOpenASAR = true;
      #withVencord = true;
      #withMoonlight = true;
    #})
    pkgs.unstable.vesktop
    pkgs.handbrake
    pkgs.unstable.teamspeak6-client

    # Hashcat
    (pkgs.hashcat.override { cudaSupport = true; })
  ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-multi-rtmp
      obs-vkcapture
      obs-backgroundremoval
    ];
    package =
      if osConfig.networking.hostName == "uGamingPC"
      then pkgs.obs-studio.override { cudaSupport = true; }
      else pkgs.obs-studio;

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
