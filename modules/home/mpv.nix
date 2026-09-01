{ pkgs, ... }:
let
  brokenPine = import ./colors.nix;
in {
  programs.mpv = {
    enable = true;

    config = {
      # General
      profile = "gpu-hq";
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "auto-safe";

      # Audio
      volume = 100;
      volume-max = 150;

      # Subtitles
      sub-auto = "fuzzy";
      sub-font = "JetBrainsMono Nerd Font";
      sub-font-size = 36;
      sub-border-size = 2;

      # OSD - Broken Pine colors
      osd-font = "JetBrainsMono Nerd Font";
      osd-font-size = 24;
      osd-color = brokenPine.text;
      osd-border-color = brokenPine.background;
      osd-border-size = 2;
      osd-bar-align-y = 0.9;

      # Screenshot
      screenshot-format = "png";
      screenshot-directory = "~/Pictures/Screenshots";

      # Keep window open after video ends
      keep-open = "yes";

      # Save position on quit
      save-position-on-quit = "yes";
    };

    bindings = {
      # Vim-like navigation
      "l" = "seek 5";
      "h" = "seek -5";
      "j" = "seek -60";
      "k" = "seek 60";
      "L" = "seek 30";
      "H" = "seek -30";

      # Volume
      "+" = "add volume 5";
      "-" = "add volume -5";

      # Playback speed
      "[" = "multiply speed 0.9";
      "]" = "multiply speed 1.1";
      "BS" = "set speed 1.0";

      # Subtitles
      "z" = "add sub-delay -0.1";
      "Z" = "add sub-delay +0.1";
    };

    scripts = with pkgs.mpvScripts; [
      mpris           # Media keys support
      uosc            # Modern UI
      thumbfast       # Thumbnails in seek bar
    ];

    scriptOpts = {
      # UOSC Broken Pine theme
      uosc = {
        color = "foreground=${brokenPine.noHash brokenPine.text},foreground_text=${brokenPine.noHash brokenPine.background},background=${brokenPine.noHash brokenPine.background},background_text=${brokenPine.noHash brokenPine.text},curtain=${brokenPine.noHash brokenPine.surface},success=${brokenPine.noHash brokenPine.green},error=${brokenPine.noHash brokenPine.red}";

        # UI settings
        timeline_style = "bar";
        timeline_size = 30;
        timeline_border = 1;
        timeline_step = 5;

        controls = "menu,gap,subtitles,<has_many_audio>audio,<has_many_video>video,<has_many_edition>editions,<stream>stream-quality,gap,space,speed,space,shuffle,loop-playlist,loop-file,gap,prev,items,next,gap,fullscreen";

        volume = "right";
        volume_size = 30;

        speed_step = 0.1;
        speed_step_is_factor = "no";

        menu_item_height = 40;
        menu_min_width = 260;

        font_bold = "yes";
        text_border = 1.2;

        # Proximity settings
        proximity_in = 40;
        proximity_out = 120;

        # Animations
        animation_duration = 100;
      };

      thumbfast = {
        spawn_first = "yes";
        network = "yes";
        hwdec = "yes";
      };
    };
  };
}
