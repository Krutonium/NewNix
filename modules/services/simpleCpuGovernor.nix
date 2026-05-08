{ ... }:
{
  flake.nixosModules.simpleCpuGovernor =
    {  ... }:
    {
      services.simpleCpuGovernor = {
        enable = true;
        target = 80;
        sampleMs = 100;
        intervalMs = 100;
        hysteresis = 10;
      };
    };
}
