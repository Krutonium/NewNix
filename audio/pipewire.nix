{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.audio;
  pw_fix_crackle = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [ 48000 ];
      "default.clock.quantum" = 800;
      "default.clock.min-quantum" = 512;
      "default.clock.max-quantum" = 1024;
    };
  };

  pw_rnnoise_config = {
    "context.modules" = [
      {
        "name" = "libpipewire-module-filter-chain";
        "args" = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";
          "filter.graph" = {
            "nodes" = [
              {
                "type" = "ladspa";
                "name" = "rnnoise";
                "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                "label" = "noise_suppressor_stereo";
                "control" = {
                  "VAD Threshold (%)" = 95.0;
                };
              }
            ];
          };
          "audio.position" = [
            "FL"
            "FR"
          ];
          "capture.props" = {
            "node.name" = "effect_input.rnnoise";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "effect_output.rnnoise";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };
in
{
  config = mkIf (cfg.server == "pipewire") {
    hardware.pulseaudio.enable = false;
    services = {
      pipewire = {
        enable = true;
        package = pkgs.unstable.pipewire;
        wireplumber.enable = true;
        audio.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse = {
          enable = true;
        };
        jack = {
          enable = false;
        };
        extraConfig.pipewire = {
          "99-input-denoise" = pw_rnnoise_config;
          "99-fix-crackle" = pw_fix_crackle;
        };
      };
    };
  };
}
