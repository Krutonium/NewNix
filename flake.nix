{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    minegrub = {
      url = "github:Lxtharia/minegrub-world-sel-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    update = {
      url = "github:ryantm/nixpkgs-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fan-controller = {
      url = "github:Krutonium/BetterFanController";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    MediaServer = {
      url = "github:Krutonium/MediaServer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    R2CC = {
      url = "github:Krutonium/InternetRadio2ComputerCraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    nvidia-patch = {
      url = "github:icewind1991/nvidia-patch-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-master,
      nixos-hardware,
      home-manager,
      update,
      nix-monitored,
      nixd,
      fan-controller,
      nur,
      R2CC,
      nvidia-patch,
      lix-module,
      MediaServer,
      sops-nix,
      minegrub,
      stylix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Generic Modules
      baseModules = [
        ./common.nix
        #lix-module.nixosModules.default
        minegrub.nixosModules.default
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        {
          nix.registry.nixos.flake = self;
          environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
          nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ];
        }
        home-manager.nixosModules.home-manager
        {
          nix.registry.nixos.flake = self;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];

      # Overlay Definitions
      overlays = {
        unstable = final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            config.nvidia.acceptLicense = true;
          };
        };
        master = final: prev: {
          master = import nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
            config.nvidia.acceptLicense = true;
          };
        };
        nixpkgsUpdate = final: prev: {
          nixpkgs-update = update.defaultPackage.x86_64-linux;
        };
        fanController = self: super: {
          BetterFanController = fan-controller.defaultPackage.x86_64-linux;
        };
        MediaServer = self: super: {
          MediaServer = MediaServer.defaultPackage.x86_64-linux;
        };
        InternetRadio2Computercraft = self: super: {
          InternetRadio2Computercraft = R2CC.defaultPackage.x86_64-linux;
        };
        monitored = self: super: {
          nixos-rebuild = super.nixos-rebuild.override { nix = self.nix-monitored; };
          nix-direnv = super.nix-direnv.override { nix = self.nix-monitored; };
          nix-monitored = inputs.nix-monitored.packages.${self.system}.default.override self;
        };
      };

      genericModulesWithOverlays = baseModules ++ [
        (
          { config, pkgs, ... }:
          {
            nixpkgs.overlays = [
              overlays.unstable
              overlays.master
              overlays.nixpkgsUpdate
              nixd.overlays.default
              overlays.fanController
              overlays.InternetRadio2Computercraft
              nur.overlays.default
              inputs.nvidia-patch.overlays.default
              overlays.MediaServer
            ];
          }
        )
      ];

      # NixOS Configuration Helper
      nixosConfiguration =
        name: deviceConfig:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = genericModulesWithOverlays ++ (with nixos-hardware.nixosModules; deviceConfig);
          # specialArgs.channels = { inherit nixpkgs nixpkgs-unstable; };
          specialArgs = { inherit inputs; };
        };

      # Common Device Modules

      commonPCModules = with nixos-hardware.nixosModules; [
        common-pc
        common-pc-ssd
      ];
      commonIntel = with nixos-hardware.nixosModules; [ common-cpu-intel ];
      commonAMD = with nixos-hardware.nixosModules; [ common-cpu-amd ];
      commonLaptop = with nixos-hardware.nixosModules; [ common-pc-laptop ];
      gpuAMD = with nixos-hardware.nixosModules; [ common-gpu-amd ];
      gpuNvidia = with nixos-hardware.nixosModules; [ common-gpu-nvidia ];
      gpuIntel = with nixos-hardware.nixosModules; [ common-gpu-intel ];
    in
    {
      ##########################
      ### Device Definitions ###
      ##########################
      nixosConfigurations = {
        uWebServer = nixosConfiguration "uWebServer" (
          commonPCModules ++ commonIntel ++ gpuAMD ++ gpuIntel ++ [ ./devices/uWebServer.nix ]
        );
        uGamingPC = nixosConfiguration "uGamingPC" (
          commonPCModules ++ commonAMD ++ gpuNvidia ++ [ ./devices/uGamingPC.nix ]
        );
        uMsiLaptop = nixosConfiguration "uMsiLaptop" (
          commonPCModules ++ commonLaptop ++ commonIntel ++ gpuIntel ++ [ ./devices/uMsiLaptop.nix ]
        );
        uServerHost = nixosConfiguration "uServerHost" (
          commonPCModules ++ commonAMD ++ gpuNvidia ++ [ ./devices/uServerHost.nix ]
        );
      };
    };
}
