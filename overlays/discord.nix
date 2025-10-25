self: super: {
  discord = super.unstable.vesktop.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/discord \
        --set DISCORD_OZONE_PLATFORM_HINT x11 \
        --set NIXOS_OZONE_WL "0" \
        --add-flags "--ozone-platform=x11"
    '';
  });
}
