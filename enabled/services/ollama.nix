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
              # Upstream ollama-cuda currently
              # builds CUDAToolkit_ROOT by concatenating several unrelated
              # cudaPackages store paths with no separator, and never
              # includes cuda_nvcc at all - so `nvcc` can never be found
              # regardless of arch. Work around it by pointing CMake at a
              # complete toolkit directly and making sure nvcc is present
              # in the build.
              nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [
                pkgs.unstable.cudaPackages.cuda_nvcc
              ];

              cmakeFlags = (prev.cmakeFlags or []) ++ [
                "-DCMAKE_CUDA_ARCHITECTURES=61"
                "-DCUDAToolkit_ROOT=${pkgs.unstable.cudaPackages.cudatoolkit}"
              ];
            }
          );
        };
      };
    };
}
