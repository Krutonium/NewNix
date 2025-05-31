{ config, pkgs, ... }:
{
  home.file = {
    ".nanorc".text = ''
      set linenumbers
      set autoindent
      set historylog
      set softwrap
      set tabstospaces
    '';
    ".steam/steam/steam_dev.cfg".text = ''
      @nClientDownloadEnableHTTP2PlatformLinux 0
    '';
    ".config/neofetch/config.conf".text = ''
      print_info() {
        info title
        info underline

        info "OS" distro
        info "Kernel" kernel
        info "Uptime" uptime
        info "CPU" cpu
        info "Memory" memory
        info "GPU" gpu
        info "Resolution" resolution
        info "Shell" shell
        info "Local IP" local_ip
        #prin "Weather" "$(curl wttr.in/?0?q?T | awk '/°(C|F)/ {printf $(NF-1) $(NF) " ("a")"} /,/ {a=$0}')"
        info cols
      }
      kernel_shorthand="on"
      distro_shorthand="on"
      os_arch="on"
      uptime_shorthand="on"
      memory_percent="on"
      memory_units="mib"
      package_managers="on"
      shell_path="off"
      shell_version="on"
      speed_type="scaling_max_freq"
      speed_shorthand="off"
      cpu_brand="on"
      cpu_speed="on"
      cpu_cores="logical"
      cpu_temp="on"
      gpu_brand="on"
      gpu_type="all"
      refresh_rate="on"
      gtk_shorthand="on"
      gtk2="on"
      gtk3="on"
      local_ip_interface=('auto')
      de_version="on"
      colors=(distro)
      bold="on"
      underline_enabled="on"
      underline_char="-"
      separator=":"
      block_range=(0 15)
      color_blocks="on"
      block_width=3
      block_height=1
      col_offset="auto"
      bar_char_elapsed="-"
      bar_char_total="="
      bar_border="on"
      bar_length=15
      bar_color_elapsed="distro"
      bar_color_total="distro"
      memory_display="on"
      image_backend="catimg"
      image_source="" #LINK TO IMAGE
      catimg_size="2"
      image_size="auto"
    '';
    ".config/MangoHud/MangoHud.conf".text = ''
      toggle_fps_limit=F1

      legacy_layout=false
      gpu_stats
      gpu_temp
      gpu_core_clock
      gpu_power
      gpu_load_change
      gpu_load_value=50,90
      gpu_load_color=FFFFFF,FF7800,CC0000
      gpu_text=GPU
      cpu_stats
      cpu_temp
      cpu_power
      cpu_load_change
      core_load_change
      cpu_load_value=50,90
      cpu_load_color=FFFFFF,FF7800,CC0000
      cpu_color=2e97cb
      cpu_text=CPU
      io_color=a491d3
      vram
      vram_color=ad64c1
      ram
      ram_color=c26693
      fps
      engine_color=eb5b5b
      gpu_color=2e9762
      wine_color=eb5b5b
      frame_timing=1
      frametime_color=00ff00
      media_player_color=ffffff
      no_display
      background_alpha=0.4
      font_size=24

      background_color=020202
      position=top-left
      text_color=ffffff
      round_corners=1
      toggle_hud=Home
      toggle_logging=Shift_L+F2
      upload_log=F5
      output_folder=/home/krutonium
      media_player_name=spotify
    '';

    #Alias bpytop as top
    ".config/fish/functions/top.fish".text = ''
      function top --wraps=btop --description 'alias top=btop'
        btop $argv;
      end
    '';
    #Alias bat as cat
    ".config/fish/functions/bat.fish".text = ''
      function cat --wraps=bat --description 'alias cat=bat'
        bat $argv;
      end
    '';
    ".config/burn-my-windows/profiles/1685604310611376.conf".text = ''
      [burn-my-windows-profile]
      profile-animation-type=1
      fire-enable-effect=false
      hexagon-enable-effect=true
    '';
    ".config/burn-my-windows/profiles/1685604429464762.conf".text = ''
      [burn-my-windows-profile]
      profile-window-type=0
      profile-animation-type=2
      fire-enable-effect=false
      snap-enable-effect=true
    '';
  };
}
