{ ... }:
{
  services.kanshi = {
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
              position = "1067,1080";
              scale = 2.25;
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
            scale = 2.25;
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
              scale = 2.25;
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
              scale = 2.25;
            }
          ];
        };
      }
    ];
  };
}
