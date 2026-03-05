{ config
, pkgs
, lib
, ...
}:
let
  openclawStateDir = "/home/krutonium/.openclaw";
in
{
  programs.openclaw = {
    enable = true;
    documents = config.lib.file.mkOutOfStoreSymlink "/home/krutonium/.config/openclaw/documents";
    config = {
      gateway = {
        mode = "local";
        auth = { token = "openclaw-local-token"; };
      };
      channels.telegram = {
        tokenFile = "/home/krutonium/.secrets/telegram-bot-token";
        allowFrom = [ 5221019324 ];
      };
      providers.ollama = {
        baseUrl = "http://10.0.0.3:11343";
      };
    };
    instances.default = {
      enable = true;
      stateDir = openclawStateDir;
      workspaceDir = "${openclawStateDir}/workspace";
      serviceMode = "user";
      config = {
        model = "claude";
        providers.claude = {
          baseUrl = "http://10.0.0.3:11343";
          auth = { token = "ollama"; };
        };
      };
    };
  };

  # Create the secrets directory
  home.file.".secrets".ensureExists = true;
  home.file.".secrets/telegram-bot-token" = {
    text = "8653856879:AAEFTGs5dCDkEWFI5dll0-vm4XV8G8WAR9M";
    onChange = ''
      chmod 600 /home/krutonium/.secrets/telegram-bot-token
    '';
  };

  # Create documents directory symlink target
  home.file.".config/openclaw/documents".ensureExists = true;

  # Create initial AGENTS.md if it doesn't exist
  home.file.".config/openclaw/documents/AGENTS.md" = {
    text = ''
      # OpenClaw Agents Configuration

      This directory contains configuration files for OpenClaw agents.
    '';
    force = false;
  };
}
