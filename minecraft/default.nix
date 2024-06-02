{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.minecraft = {
    #Goals: Create multiple Minecraft Servers. Assume they've already been configured. Use `start.sh` to start them.
    # What I have here should be replaced with somthing that can handle this more dynamically and without creating a file for
    # each modpack.

    stoneblock3 = mkOption {
      type = types.bool;
      default = false;
      description = ''
        StoneBlock 3 Server
      '';
    };
    rubberdragontrain = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable RDT Server
      '';
    };
    stoneblock3Memory = mkOption {
      type = types.int;
      default = 10240;
      description = ''
        StoneBlock 3 Server Memory in MB
      '';
    };
    gryphon = mkOption {
      type = types.bool;
      default = false;
      description = "GryphonMC";
    };
  };
  imports = [ ./stoneblock3.nix ./RubberDragonTrain.nix ./Gryphon.nix ];

}
