{ lib, ... }: {
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
  };
}

# Yes I know this isn't actually an overlay, but it cleanly sorts into here.