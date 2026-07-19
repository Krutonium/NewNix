{ ... }:
{
  flake.homeModules.git =
    { ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Krutonium";
            email = "PFCKrutonium@gmail.com";
          };
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = true;
          };
        };
        lfs.enable = true;
      };
    };
}
