{ ... }:
{
  flake.nixosModules.jellyfin =
    { config, mv, ... }:
    {
      services.jellyfin = {
        enable = true;
        group = "media";
        cacheDir = "/persist/jellyfin/cache";
        dataDir = "/persist/jellyfin/data";
        openFirewall = true;
        hardwareAcceleration = {
          enable = true;
          device = "/dev/dri/renderD128";
          type = "vaapi";
        };
        transcoding = {
          h264Crf = 23;
          h265Crf = 28;
          threadCount = 4;
          deleteSegments = true;
          encodingPreset = "auto";
          throttleTranscoding = true;
          maxConcurrentStreams = 4;
          enableHardwareEncoding = true;
          hardwareDecodingCodecs = {
            h264 = true;
            hevc = true;
            hevc10bit = true;
            mpeg2 = true;
            vc1 = true;
            vp9 = true;
            # No decode support for vp8, av1, hevcRExt10bit or 12 bit, etc
          };
          hardwareEncodingCodecs = {
            hevc = true;
          };
        };
      };
    };
}
