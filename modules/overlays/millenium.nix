{ self, inputs, ... }: {
  flake.overlays.millennium-next = final: prev:
    let
      sys = prev.stdenv.hostPlatform.system;
    in {
      millennium       = inputs.millennium.packages.${sys}.millennium;
      millennium-steam = inputs.millennium.packages.${sys}.millennium-steam;
    };
}