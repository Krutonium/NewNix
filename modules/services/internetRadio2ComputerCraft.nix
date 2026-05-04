{ ... }:
{
  flake.nixosModules.InternetRadio2Computercraft =
    { pkgs, ... }:
    {
      systemd.services.InternetRadio2Computercraft = {
        description = "Stream Internet Radio for Computercraft";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          WorkingDirectory = "/tmp";
          User = "krutonium";
          Restart = "always";
        };
        path = [
          pkgs.InternetRadio2Computercraft
          pkgs.ffmpeg-full
          pkgs.unstable.yt-dlp
        ];
        script = ''
          InternetRadio2Computercraft
        '';
      };
    };
}