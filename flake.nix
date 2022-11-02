{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";                       # NixOS release channel
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";           # NixOS unstable channel
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";              # NixOS hardware channel
    home-manager.url = "github:nix-community/home-manager/release-22.05";   # Home Manager release channel
    deploy-cs = {
      url = "github:Krutonium/deploy-cs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self }@inputs: {
    #############
    # uGamingPC #
    #############
    nixosConfiguration.uGamingPC = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./common.nix
        ./devices/uGamingPC.nix
      ];
    };
  };
}