{ ... }:
{
  flake.nixosModules.pipewire =
    {
      pkgs,
      lib,
      ...
    }:
    with lib;
    with builtins;
    let
      wp_disable_powersaving = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_input.*"; }
              { "node.name" = "~alsa_output.*"; }
            ];
            actions = {
              update-props = {
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };

      wp_disable_audio_sleep_laptop = {
        "monitor.alsa.rules" = [
          {
            matches = "alsa_output.pci-0000_00_1b.0.analog-stereo";
          }
        ];
        actions = {
          update-props = {
            "session.suspend-timeout-seconds" = 0;
          };
        };
      };

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
      services.pulseaudio.enable = false;
      services.pipewire = {
        enable = true;
        package = pkgs.pipewire;
        wireplumber = {
          enable = true;
          extraConfig."99-disable-powersave" = wp_disable_powersaving;
          extraConfig."98-disable-sleep-laptop" = wp_disable_audio_sleep_laptop;
        };
        audio.enable = true;
        alsa = {
          enable = false;
          support32Bit = false;
        };
        pulse.enable = true;
        jack.enable = false;
        extraConfig.pipewire = {
          "99-input-denoise" = pw_rnnoise_config;
          "99-fix-crackle" = pw_fix_crackle;
        };
      };
    };
}
