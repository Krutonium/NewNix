{ ... }:
{
  flake.nixosModules.vr =
    { pkgs, ... }:
    {
      services.wivrn = {
        enable = true;
        openFirewall = true;
        autoStart = true;
        package = (pkgs.wivrn.override { cudaSupport = true; });
      };
      environment.systemPackages = [ pkgs.wayvr ];
      systemd.user.services.wayvr = {
        description = "WayVR desktop overlay for OpenXR/OpenVR";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.wayvr}/bin/wayvr --replace";
          Restart = "on-failure";
        };
      };
    };
}
