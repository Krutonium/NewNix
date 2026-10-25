{ inputs, ... }:
let
  version = "1.0.0";
  nvVersion = "610.43.03";

  # Firmware is generated at build time from two pinned NVIDIA inputs
  # (same ones as packaging/arch/PKGBUILD); the upstream scripts re-check
  # every file against their own SHA-256 pins.
  mkFirmware =
    {
      lib,
      stdenvNoCC,
      fetchurl,
      python3,
      zstd,
      xz,
    }:
    let
      nvSource = fetchurl {
        url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-${nvVersion}.tar.xz";
        hash = "sha256-fhGJI8eiPtw2EU1jJzpG4+BOmvmGlaQiA+esLf6fwdw=";
      };
      nvUtils = fetchurl {
        url = "https://archive.cachyos.org/archive/cachyos-v3/nvidia-utils-${nvVersion}-1-x86_64_v3.pkg.tar.zst";
        hash = "sha256-4X58ku7/oXiw/h9A6xekcJX4/Dzkp3vxFc9b1aTfhuk=";
      };
    in
    stdenvNoCC.mkDerivation {
      pname = "gpu-unlock-firmware";
      inherit version;
      src = inputs.gpu-unlock;

      nativeBuildInputs = [
        python3
        zstd
        xz
      ];

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild
        mkdir -p assets assets.src
        tar -xf ${nvSource} -C assets.src
        python3 firmware/generate_v67.py ${nvUtils} assets
        python3 firmware/extract_boot_assets.py \
          assets.src/NVIDIA-kernel-module-source-${nvVersion} assets
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm644 -t $out/lib/firmware/gpu-unlock/${nvVersion} \
          assets/booter_load_ga102.bin \
          assets/gsp_ga10x.bin \
          assets/gsp_boot_ga102.bin \
          assets/gsp_boot_desc_ga102.bin \
          assets/v67-ga102-${nvVersion}.bin
        install -Dm644 assets/NVIDIA-LICENSE \
          $out/share/licenses/gpu-unlock-firmware/NVIDIA-LICENSE
        install -Dm644 firmware/NOTICE.md \
          $out/share/licenses/gpu-unlock-firmware/NOTICE.md
        runHook postInstall
      '';

      meta = {
        description = "Pinned NVIDIA ${nvVersion} firmware assets for gpu-unlock";
        license = [
          lib.licenses.unfree
          lib.licenses.gpl2Only
        ];
        platforms = [ "x86_64-linux" ];
      };
    };

  mkKmod =
    {
      lib,
      stdenv,
      kernel,
    }:
    stdenv.mkDerivation {
      pname = "gpu-unlock";
      version = "${version}-${kernel.version}";
      src = inputs.gpu-unlock;

      nativeBuildInputs = kernel.moduleBuildDependencies;
      hardeningDisable = [
        "pic"
        "format"
      ];

      dontConfigure = true;

      # Call kbuild directly with only what it needs. kernel.makeFlags is a
      # grab-bag meant for building the kernel itself (O=, --eval=..., etc.)
      # and breaks out-of-tree builds against the read-only dev output.
      buildPhase = ''
        runHook preBuild
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$PWD/kernel/gpu_unlock \
          ARCH=${stdenv.hostPlatform.linuxArch} \
          modules
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm644 kernel/gpu_unlock/gpu_unlock.ko \
          -t $out/lib/modules/${kernel.modDirVersion}/extra
        runHook postInstall
      '';

      meta = {
        description = "Pre-driver FP/BF16 issue-rate unlock for Nvidia RTX 3000 cards";
        homepage = "https://github.com/Zagitta/gpu-unlock";
        license = lib.licenses.gpl2Only;
        platforms = [ "x86_64-linux" ];
      };
    };
in
{
  flake.nixosModules.gpu-unlock =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.hardware.gpuUnlock;
      kernelPackages = config.boot.kernelPackages;
      firmware = kernelPackages.callPackage mkFirmware { };
      kmod = kernelPackages.callPackage mkKmod { };
    in
    {
      options.hardware.gpuUnlock = {
        enable = lib.mkEnableOption "the gpu-unlock BF16/FP16 unlock for Nvidia RTX 3000 cards";

        targets = lib.mkOption {
          type = lib.types.str;
          default = "all";
          example = "0000:21:00.0,0000:22:00.0";
          description = ''
            Value of `gpu_unlock.targets=`: `all`, or comma-separated full PCI
            addresses as printed by `lspci -D`.
          '';
        };

        resume = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Re-run the unlock after resume from suspend.";
        };

        initrd = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Load the module from the initrd, so it runs before nvidia can bind
            a card. Adds the ~85 MB GSP firmware to the initrd.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        boot.extraModulePackages = [ kmod ];
        hardware.firmware = [ firmware ];

        # mkBefore so it sits ahead of nvidia if that is also in the initrd.
        boot.initrd.kernelModules = lib.mkIf cfg.initrd (lib.mkBefore [ "gpu_unlock" ]);
        boot.kernelModules = lib.mkIf (!cfg.initrd) [ "gpu_unlock" ];

        boot.kernelParams = [
          "gpu_unlock.targets=${cfg.targets}"
        ]
        ++ lib.optional (!cfg.resume) "gpu_unlock.resume=0";
      };
    };
}