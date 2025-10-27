self: super: {
  unstable.vesktop = super.unstable.vesktop.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/vesktop \
        --set DISCORD_OZONE_PLATFORM_HINT x11 \
        --set NIXOS_OZONE_WL "0" \
        --add-flags "--ozone-platform=x11"
    '';
  });
}
