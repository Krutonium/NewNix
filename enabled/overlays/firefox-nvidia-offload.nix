{ self, ... }:
{
  flake.nixosModules.firefoxNvidiaOffload = { config, lib, pkgs, ... }:
    {
      # Self-gating: only applies the overlay on hosts where
      # hardware.nvidia.prime.offload.enable is actually true.
      # Safe to import into every host's module list.
      nixpkgs.overlays = lib.optional
        (config.hardware.nvidia.prime.offload.enable or false)
        (final: prev: {
          firefox = prev.symlinkJoin {
            name = "firefox-nvidia-offload";
            paths = [ prev.firefox ];
            nativeBuildInputs = [ prev.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/firefox --run '
                export __NV_PRIME_RENDER_OFFLOAD=1
                export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
                export __GLX_VENDOR_LIBRARY_NAME=nvidia
                export __VK_LAYER_NV_optimus=NVIDIA_only
              '
            '';
          };
        });
    };
}
