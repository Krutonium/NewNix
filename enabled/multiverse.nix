{ inputs, ... }:
{
  _module.args.mv = inputs.multiverse.lib.mkMultiverse {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
      allowInsecure = true;
    };
  };
}