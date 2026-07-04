{ ... }: {
  flake.nixosModules.obs-relay = { config, pkgs, ... }: {
    sops.secrets.twitch-stream-key = { };
    sops.secrets.youtube-stream-key = { };

    systemd.services.obs-relay = {
      description = "SRT-in, dual-RTMP-out NVENC relay";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = 5;
        ExecStart = pkgs.writeShellScript "obs-relay-start" ''
          TWITCH_KEY=$(cat ${config.sops.secrets.twitch-stream-key.path})
          YOUTUBE_KEY=$(cat ${config.sops.secrets.youtube-stream-key.path})
          exec ${pkgs.ffmpeg-full}/bin/ffmpeg -hwaccel cuda -hwaccel_output_format cuda \
            -i "srt://0.0.0.0:9999?mode=listener" \
            -filter_complex "[0:v]split=2[v1][v2]" \
            -map "[v1]" -map 0:a \
              -c:v h264_nvenc -preset p5 -rc cbr -b:v 6000k -maxrate 6000k -bufsize 12000k -g 120 -bf 2 \
              -c:a aac -b:a 160k -f flv "rtmp://live.twitch.tv/app/$TWITCH_KEY" \
            -map "[v2]" -map 0:a \
              -c:v hevc_nvenc -preset p5 -rc cbr -b:v 20000k -maxrate 20000k -bufsize 40000k \
              -g 120 -profile:v main \
              -c:a aac -b:a 192k \
              -f flv "rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_KEY"
            -map 0:v -map 0:a -c copy \
              -f rtsp -rtsp_flags listen "rtsp://0.0.0.0:8554/mezzanine"

#            -map "[v2]" -map 0:a \
#              -c:v h264_nvenc -preset p5 -rc cbr -b:v 20000k -maxrate 20000k -bufsize 40000k -g 120 -bf 2 \
#              -c:a aac -b:a 192k -f flv "rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_KEY"
        '';
      };
    };
    networking.firewall.allowedUDPPorts = [ 9999 ];
    networking.firewall.allowedTCPPorts = [ 8554 ];
  };
}
