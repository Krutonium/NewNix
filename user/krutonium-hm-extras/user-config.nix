{ pkgs, lib, ... }:
let
  javaVersions = {
    jdk8 = pkgs.jdk8;
    jdk11 = pkgs.jdk11;
    jdk17 = pkgs.jdk17;
    jdk21 = pkgs.jdk21;
    jdk24 = pkgs.jdk24;
  };

  javaLinks = lib.mapAttrs' (
    name: pkg:
    lib.nameValuePair "java/${name}" {
      source = pkg;
    }
  ) javaVersions;
in
{
  home.file = javaLinks // {
    ".face".source = ./profile.png;
    ".nanorc".text = ''
      set linenumbers
      set autoindent
      set historylog
      set softwrap
      set tabstospaces
    '';
    ".steam/steam/steam_dev.cfg".text = ''
      @nClientDownloadEnableHTTP2PlatformLinux 0
    '';
  };
  programs.mangohud.settings = {
    "toggle_fps_limit" = "F1";
    "fps_limit" = 165;
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
  xdg.configFile."openvr/openvrpaths.vrpath".text = ''
    {
      "config" :
      [
        "~/.local/share/Steam/config"
      ],
      "external_drivers" : null,
      "jsonid" : "vrpathreg",
      "log" :
      [
        "~/.local/share/Steam/logs"
      ],
      "runtime" :
      [
        "${pkgs.xrizer}/lib/xrizer"
      ],
      "version" : 1
    }
  '';
}
