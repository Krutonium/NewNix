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
        openFirewall = false;
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
      services.nginx.virtualHosts."jellyfin.${config.networking.domain}" = {
        useACMEHost = "krutonium.ca";
        forceSSL = true; # Force SSL
        locations."/".proxyPass = "http://127.0.0.1:8096"; # Proxy Gitea
        extraConfig = ''
          #limit_req zone=git_zone burst=20 nodelay;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Host $server_addr;
          proxy_set_header Referer $server_addr;
          proxy_set_header Origin $server_addr;
        '';
      };
      networking.firewall.interfaces."br0".allowedUDPPorts = [ 7359 ];
    };
}
