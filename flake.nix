{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";
    # NEW! Multiverse replaces Unstable and Master and technically every older version as well!
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils"; # Purely used to deduplicate
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nur.follows = "nur";
      inputs.flake-parts.follows = "flake-parts";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    InternetRadio2Computercraft = {
      url = "github:Krutonium/InternetRadio2Computercraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hytale-launcher-nix = {
      url = "github:JPyke3/hytale-launcher-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-cpu-governor = {
      url = "github:krutonium/simple-cpu-governor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvidia-patch = {
      url = "github:icewind1991/nvidia-patch-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    g600-key-remap-daemon = {
      url = "github:Krutonium/G600-key-remap-daemon";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    hanabi-src = {
      url = "github:Aspiand/gnome-ext-hanabi/be05483b248a583de999d4d74eb982f79d2b71c3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moonshine = {
      url = "github:hgaiser/moonshine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    win98se-plymouth = {
      url = "github:nilp0inter/plymouth-theme-win98se-inspired-nixos-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xwaylandvideobridge = {
      url = "github:KDE/xwaylandvideobridge";
    };
  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    } (inputs.import-tree ./enabled);
}
