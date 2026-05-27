{ ... }:
{
  flake.overlays.discord-canary-vulkan-patch = self: super: {
    discord-canary = (super.discord-canary.override {
      withVencord = true;
    }).overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        index_js="$out/opt/DiscordCanary/resources/discord_voice/index.js"

        # Remove "vaapi",
        awk '{ gsub(/"vaapi"[[:space:]]*,[[:space:]]*/, "") } 1' "$index_js" > "$index_js.tmp" && mv "$index_js.tmp" "$index_js"

        # Add "linux-nvenc","useCaptureDeviceForEncode" after "linux-v4l2" if not already present
        if ! grep -q '"linux-nvenc"' "$index_js"; then
          awk '{ gsub(/"linux-v4l2",/, "\"linux-v4l2\",\"linux-nvenc\",\"useCaptureDeviceForEncode\",") } 1' "$index_js" > "$index_js.tmp" && mv "$index_js.tmp" "$index_js"
        fi

        # Add "linux-vulkan" after the nvenc block if not already present
        if ! grep -q '"linux-vulkan"' "$index_js"; then
          awk '{ gsub(/"linux-v4l2"[[:space:]]*,[[:space:]]*"linux-nvenc"[[:space:]]*,[[:space:]]*"useCaptureDeviceForEncode"[[:space:]]*,/, "&\"linux-vulkan\",") } 1' "$index_js" > "$index_js.tmp" && mv "$index_js.tmp" "$index_js"
        fi

        wrapProgram "$out/opt/DiscordCanary/DiscordCanary" \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
      '';
    });
  };
}
