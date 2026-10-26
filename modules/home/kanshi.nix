{ hostName, lib, ... }:
let
  # Preserve each laptop's docked layout. Every profile includes the built-in
  # panel, so hosts without one (the Ryzen desktop) skip kanshi.
  panel = {
    precision = { scale = 2.25; dockedX = 1067; logicalWidth = 1707; }; # 3840x2160 -> 1707 px
    zenbook = { scale = 1.75; dockedX = 1024; logicalWidth = 1646; }; # 2880x1800 -> 1646 px
  }.${hostName} or null;
  # EDID identities survive connector changes when reconnecting the dock.
  samsungCriteria = "Samsung Electric Company LF24T450F ${
    if hostName == "zenbook" then "HX5W500259" else "HX5T901368"
  }";
in {
  services.kanshi = lib.mkIf (panel != null) {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = lib.optionals (hostName == "zenbook") [
      { output = { criteria = "eDP-1"; mode = "2880x1800@90.001Hz"; }; }
      { output = { criteria = samsungCriteria; mode = "1920x1080@60Hz"; }; }
      { output = { criteria = "PNP(AOC) 24G2W1G5 0x000004C7"; mode = "1920x1080@60Hz"; }; }
    ] ++ [
      {
        profile = {
          name = "tv-and-laptop";
          outputs = [
            {
              criteria = "Samsung Electric Company Q70A 0x01000E00";
              mode = "3840x2160";
              position = "${toString panel.logicalWidth},0";
              scale = 2.0;
            }
            {
              criteria = "eDP-1";
              position = "0,0";
              scale = panel.scale;
            }
          ];
        };
      }
      {
        profile = {
          name = "three-screens";
          outputs = [
            {
              criteria = samsungCriteria;
              position = if hostName == "zenbook" then "1920,0" else "0,0";
              scale = 1.0;
            }
            {
              criteria = "PNP(AOC) 24G2W1G5 0x000004C7";
              position = if hostName == "zenbook" then "0,0" else "1920,0";
              scale = 1.0;
            }
            {
              criteria = "eDP-1";
              position = "${toString panel.dockedX},1080";
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
              criteria = samsungCriteria;
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
