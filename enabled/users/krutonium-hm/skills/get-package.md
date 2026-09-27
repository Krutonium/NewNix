---
name: ephemeral-nix-packages
description: Use this skill whenever a command isn't found on a NixOS/Nix system and a CLI tool is needed temporarily - jq, ripgrep, a compiler, whatever - without editing any system or flake config. Trigger on "command not found" errors, requests to run one-off tools, or any task that needs a binary not currently on PATH in a Nix environment. Also consult this before reaching for `nix-shell -p` (legacy) or suggesting the user install something permanently just to run it once.
---

# Ephemeral Nix Packages

On NixOS (and any machine with Nix + flakes enabled), you almost never need to modify
system config or a project's `flake.nix` just to get a binary for a moment.
`nix shell nixpkgs#<pkg>` fetches (or builds) a package and puts its `bin/` on PATH
for the duration of one shell invocation, then leaves no trace.

## The core pattern

Never open a bare `nix shell nixpkgs#<pkg>` with no command - without `--command`
nothing useful runs, and behavior is version-dependent: on older Nix it drops into
an interactive subshell and the session hangs waiting for input; on Nix 2.18+ it
silently does nothing and exits 0. Always pass `--command` (or `-c`) so it runs
one thing and exits:

```
nix shell nixpkgs#ripgrep --command rg "TODO" ./src
```

Multiple packages in one invocation - all their `bin/` dirs land on PATH together:

```
nix shell nixpkgs#jq nixpkgs#curl --command bash -c 'curl -s https://api.example.com | jq .'
```

(the inner `bash -c '...'` is only needed because the payload itself is a pipeline;
a single plain command needs no wrapper)

## `nix run` vs `nix shell`

- `nix run nixpkgs#<pkg> -- <args>` - shortcut for invoking a package's *default*
  binary directly. Best when only one well-known executable needs to be called once,
  e.g. `nix run nixpkgs#hyperfine -- ./bench.sh`.
- `nix shell nixpkgs#<pkg> --command <cmd> <args>` - puts everything in the package
  on PATH first, then runs `<cmd>`. Needed when the package name doesn't match the
  binary name, when several packages' binaries need to be available to one command,
  or when chaining multiple invocations that all need the same tools.
- Some packages install several binaries prefixed with the package name (e.g.
  `ghidra` ships `ghidra-analyzeHeadless`, `ghidra-bsim`, ...). `nix run` only ever
  reaches the *default* binary; any other binary requires `nix shell`:
  `nix shell nixpkgs#ghidra --command ghidra-analyzeHeadless --help`.

Default to `nix run` for a single known binary; reach for `nix shell --command` for
anything else.

## Finding the right attribute name

If the exact package attribute isn't known:

```
nix search nixpkgs <term>
```

This is faster than guessing and re-running. search.nixos.org has the same index
if a browser is available.

### Stop: don't dig through /nix/store

If you catch yourself grepping or searching `/nix/store` directly (e.g. hunting
for a binary under a store path, listing `/nix/store/*-pkg/bin`, or looking
inside derivations to find something), you've missed the point of this skill.
You don't locate tools *inside* the store - you ask Nix to put a package's
`bin/` on PATH with `nix run nixpkgs#<pkg>` or `nix shell nixpkgs#<pkg> --command <cmd>`.
If the attribute name is unknown, use `nix search nixpkgs <term>`. The store is
Nix's cache; it is not something to be browsed or grepped.

## Prefer this over `environment.systemPackages`, always

`nix shell nixpkgs#<pkg>` is the default way to get a tool on PATH for a task -
full stop. Do **not** propose adding a package to `environment.systemPackages`
(or a Home Manager profile) just to satisfy something needed for the current
task, even if the same tool keeps coming up across sessions. Ephemeral access
is the preferred steady state here, not a fallback for one-off cases.

## Exception: devShells

The one case where a package should be added somewhere durable is a project's
own `devShells`, and only when already working inside that project's
`flake.nix` (creating one, or extending one that already exists) - not as a
general escalation path. In that context, prefer adding the package to the
devShell over reaching for `nix shell nixpkgs#` on every invocation, since the
whole point of a devShell is to make the tool available for the duration of
work on that project without repeating the incantation:

```nix
{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = [ pkgs.<pkg> ];
    };
  };
}
```

Outside of that devShell-authoring/editing context, keep using
`nix shell nixpkgs#<pkg> --command <cmd>` per invocation.

## Environment notes

- `nixpkgs#<pkg>` resolves through the flake registry, which usually tracks
  `nixos-unstable` - it is **not** guaranteed to match whatever `nixpkgs` revision
  a given `flake.lock` has pinned. That's fine for ephemeral tool use; if a build
  needs to match an exact pinned nixpkgs (e.g. to hit a self-hosted binary cache
  rather than rebuild from source), reference it explicitly instead:
  `nix shell github:NixOS/nixpkgs/<rev-or-branch>#<pkg>`.
- Avoid `nix-shell -p <pkg>` (the older, non-flake channel-based command) - it's
  slower to resolve and inconsistent with a flake-based setup.
- If the shell hangs with no output, it's almost certainly because `--command`
  was omitted and Nix dropped into an interactive shell - kill it and retry with
  `--command` (on Nix 2.18+ it will instead exit 0 silently having done nothing,
  so re-run with `--command` either way).
