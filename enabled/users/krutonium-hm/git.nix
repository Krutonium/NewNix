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
            signingKey = "~/.ssh/id_ed25519.pub";
          };
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = true;
          };
          gpg = {
            format = "ssh";
          };
          commit = {
            gpgSign = true;
          };
        };
        lfs.enable = true;
      };
    };
}
