{
  self,
  inputs,
  mv,
  ...
}:
{
  # Overlay: wrap vesktop so it always launches under XWayland instead of
  # native Wayland. This is the workaround for the GNOME/mutter + NVIDIA
  # DMA-BUF screenshare tearing bug — running under X11 sidesteps the
  # broken path entirely.
  flake.overlays.vesktop-x11-screenshare = final: prev: {
    vesktop = prev.vesktop.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/vesktop \
          --set XDG_SESSION_TYPE x11 \
          --set-default GDK_BACKEND x11 \
          --add-flags "--ozone-platform=x11"
      '';
    });
  };

  # NixOS module: pulls in the overlay above, installs xwaylandvideobridge,
  # and runs it as a user service so full-screen (not just single-window)
  # sharing keeps working once vesktop is forced onto X11.
  flake.nixosModules.discord-x11-screenshare =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      xwaylandvideobridge = mv.fast.version "xwaylandvideobridge" "0.4.0";
    in
    {
      nixpkgs.overlays = [ self.overlays.vesktop-x11-screenshare ];

      environment.systemPackages = [ xwaylandvideobridge ];

      systemd.user.services.xwaylandvideobridge = {
        description = "XWayland Video Bridge — lets XWayland clients (e.g. vesktop) capture native Wayland windows/outputs for full-screen sharing";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${xwaylandvideobridge}/bin/xwaylandvideobridge";
          Restart = "on-failure";
        };
      };
    };
}
