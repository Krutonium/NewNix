{ pkgs, ... }:
{
  # Install packages specific to this desktop:
  home.packages = with pkgs; [
    wofi
    kitty
    waybar
    hyprpaper
    gnome.nautilus
  ];

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${./wallpaper.png}
    wallpaper = ,${./wallpaper.png}
    splash = true
  '';

  home.file.".config/waybar/config.disabled".text = ''
    {
      "layer": "top",
      "modules-left": ["sway/workspaces", "sway/mode"],
      "modules-center": ["sway/window"],
      "modules-right": ["battery", "clock"],
      "sway/window": {
        "max-length": 50
      },
      "battery": {
        "format": "{capacity}% {icon}",
        "format-icons": ["<U+F244>", "<U+F243>", "<U+F242>", "<U+F241>", "<U+F240>"]
      },
      "clock": {
         "format-alt": "{:%a, %d. %b  %H:%M}"
      }
    }
  '';

  # I originally tried to use `wayland.windowManager.hyprland.settings` but it didn't work.
  # It seems to choke as soon as you need more than 1 instance of somthing.
  # For example, I have 3 monitors and I want to set the position of each one.

  # Instead we're just going to write the file.
  home.file.".config/hypr/hyprland.conf".text = ''
    # Monitor Layout
    monitor = DP-1, 1920x1080@165, 3840x0, 1, vrr, 1
    monitor = DP-2, 1920x1080@165, 0x0, 1, vrr, 1
    monitor = DP-3, 1920x1080@165, 1920x0, 1, vrr, 1
    # DP-2 is the lefty monitor
    # DP-3 is the center monitor
    # DP-1 is the righty monitor
    workspace = 1, monitor:DP-1, persistent:true
    workspace = 2, monitor:DP-3, persistent:true
    workspace = 3, monitor:DP-2, persistent:true


    # Default Programs:
    $terminal = kitty
    $menu = wofi --show drun
    $fileManager = nautilus

    # Autostart:
    # exec-once $terminal
    # exec-once = waybar
    exec-once = hyprpaper

    exec-once = vesktop
    exec-once = telegram-desktop

    windowrule = workspace 6, vesktop
    windowrule = workspace 6, Telegram

    # Look and Feel
    general {
        gaps_in = 2
        gaps_out = 5

        border_size = 2

        col.active_border = rgba(33ccffee) rgba (00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)

        resize_on_border = true
        allow_tearing = false
        layout = dwindle
    }
    decoration {
        rounding = 5
        active_opacity = 1.0
        inactive_opacity = 1.0

        drop_shadow = true
        shadow_range = 4
        shadow_render_power = 3

        blur {
            enabled = true
            size = 5
            passes = 2

            vibrancy = 0.15
        }
    }

    animations {
        enabled = true
        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
    }

    master {
        new_status = master
    }

    misc {
        force_default_wallpaper = -1
        disable_hyprland_logo = false
    }

    # Keybindings/Input
    input {
        kb_layout = us

        follow_mouse = 1
        sensitivity = 0
    }
    # Keybindings

    $mainMod = SUPER
    $altMod = ALT
    $ctrlMod = CTRL

    bind = $mainMod, Q, exec, $terminal
    bind = $mainMod, C, killactive
    bind = $mainMod, L, exit
    bind = $mainMod, E, exec, $fileManager
    bind = $mainMod, R, exec, $menu
    bind = $mainMod, F, exec, firefox

    # Move focus with mainMod + arrow keys
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d

    # Switch workspaces with mainMod + [0-9]
    bind = $ctrlMod & $altMod, 1, workspace, 1
    bind = $ctrlMod & $altMod, 2, workspace, 2
    bind = $ctrlMod & $altMod, 3, workspace, 3
    bind = $ctrlMod & $altMod, 4, workspace, 4
    bind = $ctrlMod & $altMod, 5, workspace, 5
    bind = $ctrlMod & $altMod, 6, workspace, 6
    bind = $ctrlMod & $altMod, 7, workspace, 7
    bind = $ctrlMod & $altMod, 8, workspace, 8
    bind = $ctrlMod & $altMod, 9, workspace, 9
    bind = $ctrlMod & $altMod, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow
  '';
}
