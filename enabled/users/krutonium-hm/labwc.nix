{ ... }:
{
  flake.homeModules.labwc = { config, lib, pkgs, ... }:
    let
      cfg = config.wayland.windowManager.labwc;
    in
    {
      config = lib.mkIf cfg.enable {
        xdg.configFile."labwc/rc.xml".text = ''
          <?xml version="1.0"?>
          <labwc_config>
            <core>
              <gap>0</gap>
              <adaptiveSync>no</adaptiveSync>
            </core>

            <theme>
              <name>Default</name>
              <cornerRadius>0</cornerRadius>
              <font place="ActiveWindow">
                <name>sans</name>
                <size>10</size>
              </font>
            </theme>

            <keyboard>
              <default />
              <keybind key="W-Return">
                <action name="Execute" command="foot" />
              </keybind>
              <keybind key="W-d">
                <action name="Execute" command="fuzzel" />
              </keybind>
              <keybind key="W-q">
                <action name="Close" />
              </keybind>
              <keybind key="W-S-e">
                <action name="Exit" />
              </keybind>
              <keybind key="A-Tab">
                <action name="NextWindow" />
              </keybind>
              <keybind key="W-f">
                <action name="ToggleMaximize" />
              </keybind>
            </keyboard>

            <mouse>
              <default />
              <context name="Root">
                <mousebind button="Right" action="Press">
                  <action name="ShowMenu" menu="root-menu" />
                </mousebind>
              </context>
            </mouse>

            <windowRules>
              <windowRule identifier="*">
                <action name="AutoPlace" />
              </windowRule>
            </windowRules>
          </labwc_config>
        '';

        xdg.configFile."labwc/menu.xml".text = ''
          <?xml version="1.0"?>
          <openbox_menu>
            <menu id="root-menu" label="Menu">
              <item label="Terminal">
                <action name="Execute" command="foot" />
              </item>
              <item label="Launcher">
                <action name="Execute" command="fuzzel" />
              </item>
              <separator />
              <item label="Reload">
                <action name="Reconfigure" />
              </item>
              <item label="Exit">
                <action name="Exit" />
              </item>
            </menu>
          </openbox_menu>
        '';

        xdg.configFile."labwc/autostart" = {
          text = ''
            #!/bin/sh
            waybar &
            mako &
            swaybg -c '#1e1e2e' &
          '';
          executable = true;
        };

        home.packages = with pkgs; [
          foot
          fuzzel
          waybar
          mako
          swaybg
        ];
      };
    };
}
