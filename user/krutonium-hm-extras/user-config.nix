{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  javaVersions = {
    jdk8 = pkgs.jdk8;
    jdk11 = pkgs.jdk11;
    jdk17 = pkgs.jdk17;
    jdk21 = pkgs.jdk21;
    jdk25 = pkgs.jdk25;
  };

  javaLinks = lib.mapAttrs' (
    name: pkg:
    lib.nameValuePair "java/${name}" {
      source = pkg;
    }
  ) javaVersions;

  MajorasMask = builtins.fetchurl {
    url = "https://dl.krutonium.ca/mm.us.rev1.rom.z64";
    name = "mm.us.rev1.rom.z64"; # this sets the filename in the Nix store
    sha256 = "sha256:0arzwhxmxgyy6w56dgm5idlchp8zs6ia3yf02i2n0qp379dkdcgg";
  };


in
{
  home.file = javaLinks // {
    ".face".source = ./assets/profile.png;
    ".nanorc".text = ''
      set linenumbers
      set autoindent
      set historylog
      set softwrap
      set tabstospaces
    '';
    #".steam/steam/steam_dev.cfg".text = ''
    #  @nClientDownloadEnableHTTP2PlatformLinux 0
    #'';
    "ROMS/MajorasMask.z64" = {
      source = MajorasMask;
    };
  };

  programs.mangohud.settings = {
    "toggle_fps_limit" = "F1";
    "fps_limit" = 60;
    "fps_limit_method" = "early";
    "gpu_stats" = true;
    "gpu_temp" = true;
    "gpu_core_clock" = true;
    "gpu_power" = true;
    "gpu_load_change" = true;
    "gpu_load_value" = "50,90";
    "cpu_stats" = true;
    "cpu_temp" = true;
    "cpu_power" = true;
    "cpu_load_change" = true;
    "core_load_change" = true;
    "cpu_load_value=50,90" = true;
    "cpu_text" = "CPU";
    "vram" = true;
    "ram" = true;
    "fps" = true;
    "frame_timing" = 1;
    "toggle_hud" = "F10";
    "media_player" = true;
    "permit_upload" = true;
    "cpu_mhz" = true;
    "gamemode" = true;
    "show_fps_limit" = true;
    "round_corners" = 15.0;
  };
  xdg.configFile."MangoHud/MangoHud.conf".text = lib.mkAfter ''
    # override only font appearance
    font_size = 24
    font_size_text = 14
    font_scale = 1
  '';

  xdg.configFile."openvr/openvrpaths.vrpath" =
    lib.mkIf (osConfig.networking.hostName == "uGamingPC")
      {
        force = true;
        text = builtins.toJSON {
          config = [ "~/.local/share/Steam/config" ];
          external_drivers = null;
          jsonid = "vrpathreg";
          log = [ "~/.local/share/Steam/logs" ];
          # runtime = [ "${pkgs.xrizer}/lib/xrizer" ];
          version = 1;
        };
      };

}
