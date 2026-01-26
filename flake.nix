{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    jetbrains-plugins.url = "github:nix-community/nix-jetbrains-plugins";
    minegrub = {
      url = "github:Lxtharia/minegrub-world-sel-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };
  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixpkgs-master
    , nixos-hardware
    , home-manager
    , update
    , nixd
    , fan-controller
    , nur
    , R2CC
    , MediaServer
    , sops-nix
    , minegrub
    , stylix
    , nixpkgs-xr
    , plasma-manager
    , jetbrains-plugins
    , nix-cachyos-kernel
    , ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Generic Modules
      baseModules = [
        ./common.nix
        #lix-module.nixosModules.default
        minegrub.nixosModules.default
        stylix.nixosModules.stylix
        nixpkgs-xr.nixosModules.nixpkgs-xr
        sops-nix.nixosModules.sops
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
          home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
        }
      ];

      # Overlay Definitions
      overlays = {
        unstable = _final: _prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            config.nvidia.acceptLicense = true;
          };
        };
        master = _final: _prev: {
          master = import nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
            config.nvidia.acceptLicense = true;
          };
        };
        nixpkgsUpdate = _final: _prev: {
          nixpkgs-update = update.defaultPackage.x86_64-linux;
        };
        fanController = _self: _super: {
          BetterFanController = fan-controller.defaultPackage.x86_64-linux;
        };
        MediaServer = _self: _super: {
          MediaServer = MediaServer.defaultPackage.x86_64-linux;
        };
        InternetRadio2Computercraft = _self: _super: {
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
          { ... }:
          {
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.pinned
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
        _name: deviceConfig:
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
        uWebServer = nixosConfiguration "uWebServer" (commonPCModules ++ commonIntel ++ gpuAMD ++ gpuIntel ++ [ ./devices/uWebServer.nix ]);
        uGamingPC = nixosConfiguration "uGamingPC" (commonPCModules ++ commonAMD ++ gpuNvidia ++ [ ./devices/uGamingPC.nix ]);
        uMsiLaptop = nixosConfiguration "uMsiLaptop" (commonPCModules ++ commonLaptop ++ commonIntel ++ gpuIntel ++ [ ./devices/uMsiLaptop.nix ]);
        uServerHost = nixosConfiguration "uServerHost" (commonPCModules ++ commonAMD ++ gpuNvidia ++ [ ./devices/uServerHost.nix ]);
      };
      devShells.${system}.default =
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        pkgs.mkShell {
          packages = [
            pkgs.jetbrains.idea
          ];
          shellHook = ''
            echo "Launching IntelliJ IDEA for $(pwd)…"
            idea-ultimate . 2>/dev/null &
          '';
        };
    };
}
