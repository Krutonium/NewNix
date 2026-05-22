{ self, ... }:
{
  flake.nixosModules.ollama_host =
    { config, pkgs, ... }:
    let
    in
    {
      services = {
        ollama = {
          enable = true;
          host = "0.0.0.0";
          port = 11434;
          openFirewall = true;
          acceleration = "cuda";
          package = pkgs.unstable.ollama-cuda.overrideAttrs (
            final: prev: {
              preBuild = ''
                cmake -B build \
                  -DCMAKE_SKIP_BUILD_RPATH=ON \
                  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
                  -DCMAKE_CUDA_ARCHITECTURES='61' \

                cmake --build build -j $NIX_BUILD_CORES
              '';
            }
          );
        };
        nextjs-ollama-llm-ui = {
          enable = true;
          hostname = "0.0.0.0";
          ollamaUrl = "http://127.0.0.1:11434";
          port = 3440;
        };
      };
      networking.firewall.allowedTCPPorts = [ 3440 ];
    };
}
