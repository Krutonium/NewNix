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
          package = pkgs.unstable.ollama-cuda.overrideAttrs (
            final: prev: {
              cmakeFlags = (prev.cmakeFlags or []) ++ [
                "-DCMAKE_CUDA_ARCHITECTURE=61"
              ];
            }
          );
        };
      };
    };
}
