{ ... }:
{
  flake.nixosModules.ollama_host =
    {
      mv,
      ...
    }:
    let
    in
    {
      services = {
        ollama = {
          enable = true;
          host = "0.0.0.0";
          port = 11434;
          openFirewall = true;
          package = mv.tip.ollama-cuda.overrideAttrs (
            final: prev: {
              # Upstream ollama-cuda currently
              # builds CUDAToolkit_ROOT by concatenating several unrelated
              # cudaPackages store paths with no separator, and never
              # includes cuda_nvcc at all - so `nvcc` can never be found
              # regardless of arch. Work around it by pointing CMake at a
              # complete toolkit directly and making sure nvcc is present
              # in the build.
              nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [
                mv.tip.cudaPackages.cuda_nvcc
              ];

              cmakeFlags = (prev.cmakeFlags or [ ]) ++ [
                "-DCMAKE_CUDA_ARCHITECTURES=61"
                "-DCUDAToolkit_ROOT=${mv.tip.cudaPackages.cudatoolkit}"
              ];
            }
          );
        };
      };
    };
}
