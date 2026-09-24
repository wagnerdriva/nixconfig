{ hostName, lib, ... }:
let
  # The panel sits centered below the two 1920 px monitors: its x offset is
  # (3840 - logical width) / 2 at the chosen scale. Every profile includes the
  # built-in panel, so hosts without one (the Ryzen desktop) skip kanshi.
  panel = {
    precision = { scale = 2.25; centeredX = 1067; }; # 3840x2160 -> 1707 px
    zenbook = { scale = 1.75; centeredX = 1097; }; # 2880x1800 -> 1646 px
  }.${hostName} or null;
in {
  services.kanshi = lib.mkIf (panel != null) {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile = {
          name = "three-screens";
          outputs = [
            {
              criteria = "Samsung Electric Company LF24T450F HX5T901368";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "PNP(AOC) 24G2W1G5 0x000004C7";
              position = "1920,0";
              scale = 1.0;
            }
            {
              criteria = "eDP-1";
              position = "${toString panel.centeredX},1080";
              scale = panel.scale;
            }
          ];
        };
      }
      {
        profile = {
          name = "laptop-only";
          outputs = [{
            criteria = "eDP-1";
            position = "0,0";
            scale = panel.scale;
          }];
        };
      }
      {
        profile = {
          name = "samsung-and-laptop";
          outputs = [
            {
              criteria = "Samsung Electric Company LF24T450F HX5T901368";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "eDP-1";
              position = "0,1080";
              scale = panel.scale;
            }
          ];
        };
      }
      {
        profile = {
          name = "aoc-and-laptop";
          outputs = [
            {
              criteria = "PNP(AOC) 24G2W1G5 0x000004C7";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "eDP-1";
              position = "0,1080";
              scale = panel.scale;
            }
          ];
        };
      }
    ];
  };
}
