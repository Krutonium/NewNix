{ config, pkgs, ... }:
let

  sshr = pkgs.writeShellScriptBin "sshr" ''
    ssh $@
    until !!; do sleep 5 ; done
  '';
  updateindex = pkgs.writeShellScriptBin "updateindex" ''
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    wget -N https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-linux -O files
    echo Update Complete.
  '';
  why-installed = pkgs.writeShellScriptBin "why-installed" ''
    nix why-depends /run/current-system $(command -v $1)
  '';
  where-installed = pkgs.writeShellScriptBin "where-installed" ''
    nix eval --json "/etc/nixos#nixosConfigurations.$(hostname).options.environment.systemPackages.files" | jq -r ".[]" | xargs rg $1
  '';

in
{
  environment.systemPackages = [ sshr updateindex why-installed where-installed pkgs.jq ];
}
