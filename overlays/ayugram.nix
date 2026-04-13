# overlay.nix
#
# Replaces the nixpkgs ayugram-desktop with the latest commit on the
# AyuGramDesktop `dev` branch.
#
# ── BEFORE FIRST USE ────────────────────────────────────────────────────────
#
#  1. Find the current HEAD commit of the dev branch:
#
#       curl -s https://api.github.com/repos/AyuGram/AyuGramDesktop/commits/dev \
#         | jq -r '.sha'
#
#     Paste that 40-character SHA as the value of `rev` below.
#
#  2. Get the Nix hash for that commit (with submodules):
#
#       nix-shell -p nix-prefetch-git --run \
#         "nix-prefetch-git --fetch-submodules \
#            https://github.com/AyuGram/AyuGramDesktop <SHA>"
#
#     Or with the newer `nix` CLI:
#
#       nix flake prefetch \
#         "github:AyuGram/AyuGramDesktop/<SHA>?submodules=1"
#
#     Paste the resulting hash (sri format: "sha256-…") as the value of
#     `hash` below, and set `vendorHash` the same way if it changed.
#
#  3. Whenever you want to update to a newer dev commit, repeat steps 1–2
#     and update both `rev` and `hash`.
#
# ── USAGE ───────────────────────────────────────────────────────────────────
#
#  Add to your NixOS configuration (flake or classic channel):
#
#  • Flake (nixpkgs input):
#
#      nixpkgs.overlays = [ (import ./overlay.nix) ];
#
#  • Classic /etc/nixos/configuration.nix:
#
#      nixpkgs.overlays = [ (import /path/to/overlay.nix) ];
#
# ────────────────────────────────────────────────────────────────────────────

final: prev: {
  ayugram-desktop = prev.ayugram-desktop.overrideAttrs (oldAttrs: rec {
    # Human-readable version label; adjust to taste.
    version = "dev-unstable";

    src = prev.fetchFromGitHub {
      owner = "AyuGram";
      repo  = "AyuGramDesktop";

      # ── REPLACE THIS ──────────────────────────────────────────────────────
      # Paste the full 40-character commit SHA from the `dev` branch here.
      rev  = "e37bbb2bb767bf1cfed73489002ace514acd297f";

      # ── REPLACE THIS ──────────────────────────────────────────────────────
      # Paste the sri hash produced by nix-prefetch-git (or `nix store
      # prefetch-file`) here.  Start with a fake hash and let the build error
      # tell you the correct one if you prefer:
      #   hash = "";   # triggers a mismatch error that prints the real hash
      hash = "sha256-TW9kfKlkTpDUiilNHqK4Hwxl9BpWlmAsldHF06o6aaE=";

      fetchSubmodules = true;
    };

    # Strip the upstream changelog / release-notes URL that references a
    # version tag — it won't exist for an untagged dev commit.
    meta = oldAttrs.meta // {
      changelog = "https://github.com/AyuGram/AyuGramDesktop/commits/dev";
    };
  });
}
