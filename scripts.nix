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
    nix-store --query --referrers $(nix-instantiate '<nixpkgs>' -A $1)
  '';
  where-installed = pkgs.writeShellScriptBin "where-installed" ''
    nix eval --json "/home/krutonium/NixOS/.#nixosConfigurations.$(hostname).options.environment.systemPackages.files" | jq -r ".[]" | xargs rg $1
  '';
  zink = pkgs.writeShellScriptBin "zink" ''
    MESA_LOADER_DRIVER_OVERRIDE=zink $@
  '';
  update = pkgs.writeShellScriptBin "nupdate" ''
    cd ~/NixOS
    git stash save "Pre Pull" --include-untracked
    git pull
    git stash pop
    nix flake update --commit-lock-file
    git push
  '';
  switch = pkgs.writeShellScriptBin "nswitch" ''
    cd ~/NixOS
    git stash save "Pre Pull" --include-untracked
    git pull
    git stash pop
    sudo nixos-rebuild --flake .#$(uname -n) switch
    #nix profile diff-closures --profile /nix/var/nix/profiles/system
  '';
  boot = pkgs.writeShellScriptBin "nboot" ''
    cd ~/NixOS
    git stash save "Pre Pull" --include-untracked
    git pull
    git stash pop
    sudo nixos-rebuild --flake .#$(uname -n) boot
  '';
  commit = pkgs.writeShellScriptBin "ncommit" ''
    cd ~/NixOS
    git add .
    git commit
    git push
  '';
  cleanup = pkgs.writeShellScriptBin "cleanup" ''
    sudo nix-collect-garbage -d
    nix-collect-garbage -d
  '';
  relinkrepo = pkgs.writeShellScriptBin "relinkrepo" ''
    cd ~/NixOS
    git remote set-url origin forgejo@gitea.krutonium.ca:Krutonium/NixOS.git
  '';
  explain = pkgs.writeShellScriptBin "explain" ''
    ${pkgs.unstable.gh}/bin/gh explain "$@"
  '';
  help = pkgs.writeShellScriptBin "help" ''
    ${pkgs.unstable.gh}/bin/gh suggest "$@"
  '';
in
{
  environment.systemPackages = [ sshr updateindex why-installed where-installed pkgs.jq zink update switch boot commit cleanup relinkrepo explain help ];
}
