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
      pw_rnnoise_source = {
        "context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.description" = "Noise Canceling source";
              "media.name" = "Noise Canceling source";
              "filter.graph" = {
                "nodes" = [
                  {
                    "type" = "ladspa";
                    "name" = "rnnoise";
                    "plugin" = "librnnoise_ladspa";
                    "label" = "noise_suppressor_mono";
                    "control" = {
                      "VAD Threshold (%)" = 50.0;
                    };
                  }
                ];
              };
              "audio.channels" = 1;
              "audio.position" = [ "MONO" ];
              "capture.props" = {
                "node.name" = "capture.rnnoise_source";
                "node.passive" = true;
                "audio.rate" = 48000;
              };
              "playback.props" = {
                "node.name" = "rnnoise_source";
                "media.class" = "Audio/Source";
                "audio.rate" = 48000;
              };
            };
          }
        ];
      };
      wp_set_rnnoise_default = {
        "wireplumber.settings" = {
          "default.configured.audio.source" = "rnnoise_source";
        };
      };
    in
    {
      services.pulseaudio.enable = false;
      services.pipewire = {
        enable = true;
        package = pkgs.pipewire;
        extraLadspaPackages = [ pkgs.rnnoise-plugin ];
        wireplumber = {
          enable = true;
          extraConfig."99-disable-powersave" = wp_disable_powersaving;
          extraConfig."98-disable-sleep-laptop" = wp_disable_audio_sleep_laptop;
          extraConfig."51-rnnoise-default" = wp_set_rnnoise_default;
        };
        audio.enable = true;
        alsa = {
          enable = false;
          support32Bit = false;
        };
        pulse.enable = true;
        jack.enable = false;
        extraConfig.pipewire = {
          "99-fix-crackle" = pw_fix_crackle;
          "99-input-denoising" = pw_rnnoise_source;
        };
      };
    };
}
