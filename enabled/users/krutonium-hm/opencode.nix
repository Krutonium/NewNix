{ ... }:
{
  flake.homeModules.opencode =
    { pkgs, mv, ... }:
    {
      # I want to preface this with the following statement: I don't use this for programming.
      # I use it because it's handy for tasks that I know how to do, and how to verify is done correctly
      # And honestly because there's a lot of neat things it can do - Like find me computer parts while I use
      # the washroom.
      programs.opencode = {
        enable = true;
        package = mv.fast.tip.opencode;
        web.enable = true;
        skills = {
          get-package = ./skills/get-package.md;
        };
        enableMcpIntegration = true;
      };
      programs.mcp = {
        enable = true;
        servers.playwright = {
          command = "${mv.fast.tip.playwright-mcp}/bin/playwright-mcp";
          args = [
            "--browser"
            "chromium"
            "--user-data-dir"
            "/home/krutonium/.local/share/playwright-mcp-profile"
          ];
        };
      };
    };
}
