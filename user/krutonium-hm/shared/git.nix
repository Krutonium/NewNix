{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Krutonium";
        email = "PFCKrutonium@gmail.com";
      };
    };
    lfs.enable = true;
  };
}
