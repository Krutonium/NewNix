{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-master, nixos-hardware, home-manager, update, 
  nix-monitored, nixd, fan-controller, nur, R2CC, nvidia-patch, ... }@inputs:
    let
      system = "x86_64-linux";

      # Generic Modules
      baseModules = [
        ./common.nix
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
          unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; config.nvidia.acceptLicense = true; };
        };
        master = final: prev: {
          master = import nixpkgs-master { inherit system; config.allowUnfree = true; config.nvidia.acceptLicense = true; };
        };
        nixpkgsUpdate = final: prev: {
          nixpkgs-update = update.defaultPackage.x86_64-linux;
        };
        fanController = self: super: {
          BetterFanController = fan-controller.defaultPackage.x86_64-linux;
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
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [
            overlays.unstable
            overlays.master
            overlays.nixpkgsUpdate
            nixd.overlays.default
            overlays.fanController
            overlays.InternetRadio2Computercraft
            nur.overlays.default
            inputs.nvidia-patch.overlays.default
          ];
        })
      ];

      # NixOS Configuration Helper
      nixosConfiguration = name: deviceConfig: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = genericModulesWithOverlays ++ (with nixos-hardware.nixosModules; deviceConfig);
        specialArgs.channels = { inherit nixpkgs nixpkgs-unstable; };
      };

      # Common Device Modules
      commonPCModules = with nixos-hardware.nixosModules; [ common-pc common-pc-ssd ];
      commonIntel = with nixos-hardware.nixosModules; [ common-cpu-intel ];
      commonAMD = with nixos-hardware.nixosModules; [ common-cpu-amd ];
      commonLaptop = with nixos-hardware.nixosModules; [ common-pc-laptop ];
      gpuAMD = with nixos-hardware.nixosModules; [ common-gpu-amd ];
      gpuNvidia = with nixos-hardware.nixosModules; [ common-gpu-nvidia ];
      gpuIntel = with nixos-hardware.nixosModules; [ common-gpu-intel ];
    in
    {
      ##################
      ### uWebServer ###
      ##################
      nixosConfigurations.uWebServer = nixosConfiguration "uWebServer" (commonPCModules ++ commonIntel ++ gpuAMD ++ gpuIntel ++ [ ./devices/uWebServer.nix ]);

      #################
      ### uGamingPC ###
      #################
      nixosConfigurations.uGamingPC = nixosConfiguration "uGamingPC" (commonPCModules ++ commonAMD ++ gpuNvidia ++ [ ./devices/uGamingPC.nix ]);

      ##################
      ### uMsiLaptop ###
      ##################
      nixosConfigurations.uMsiLaptop = nixosConfiguration "uMsiLaptop" (commonPCModules ++ commonLaptop ++ commonIntel ++ gpuIntel ++ [ ./devices/uMsiLaptop.nix ]);

      #################
      ### Uncomment if needed ###
      #################
      #nixosConfigurations.uHPLaptop = nixosConfiguration "uHPLaptop" (commonPCModules ++ commonLaptop ++ commonIntel ++ [ ./devices/uHPLaptop.nix ]);
      #nixosConfigurations.uMacBookPro = nixosConfiguration "uMacBookPro" (commonPCModules ++ commonLaptop ++ commonIntel ++ [ ./devices/uMacBookPro.nix ]);
    };
}
