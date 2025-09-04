# overlays/zed-editor-git.nix
self: super:

{
  zed-editor = super.zed-editor.overrideAttrs (
    old:
    let
      # Track a branch or pin a specific commit:
      rev = "28c78d2d85c81d7ea9a0e3dbab5db8a8bf0e9f55";
      hash = "sha256-uebGTQC+YZx2vlNir/IoEu2tTUA4w7rRrsBcb6CQtto=";
      short = builtins.substring 0 8 rev;
    in
    rec {
      # Show git-ish version in --version etc.
      version = "unstable-${short}";

      # Switch to rev/hash (SRI). Nix will print the real hash on first build.
      src = super.fetchFromGitHub {
        owner = "zed-industries";
        repo = "zed";
        rev = rev;
        hash = hash; # replace with the hash Nix suggests
      };

      cargoDeps = self.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-rVsg1Un3AlW5flxOQm3uf6LUKF/VyxSkitJLX5BQapU=";
      };

      # Keep existing patches & cargoPatches unless you *know* they’re no longer needed
      patches = old.patches;
      cargoPatches = old.cargoPatches;
    }
  );
}
