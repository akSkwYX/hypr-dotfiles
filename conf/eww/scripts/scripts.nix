{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/eww/scripts/bar/battery" = {
      text = builtins.readFile ./bar/battery;
      executable = true;
      target = ".config/eww/scripts/bar/battery";
    };

    ".config/eww/scripts/bar/mem-ad" = {
      text = builtins.readFile ./bar/mem-ad;
      executable = true;
      target = ".config/eww/scripts/bar/mem-ad";
    };

    ".config/eww/scripts/bar/memory" = {
      text = builtins.readFile ./bar/memory;
      executable = true;
      target = ".config/eww/scripts/bar/memory";
    };

    ".config/eww/scripts/bar/music_info" = {
      text = builtins.readFile ./bar/music_info;
      executable = true;
      target = ".config/eww/scripts/bar/music_info";
    };

    ".config/eww/scripts/bar/pop" = {
      text = builtins.readFile ./bar/pop;
      executable = true;
      target = ".config/eww/scripts/bar/pop";
    };

    ".config/eww/scripts/bar/workspace" = {
      text = builtins.readFile ./bar/workspace;
      executable = true;
      target = ".config/eww/scripts/bar/workspace";
    };

    ".config/eww/scripts/bar/wifi" = {
      text = builtins.readFile ./bar/wifi;
      executable = true;
      target = ".config/eww/scripts/bar/wifi";
    };

    ".config/eww/scripts/bar/volume_icon" = {
      text = builtins.readFile ./bar/volume_icon;
      executable = true;
      target = ".config/eww/scripts/bar/volume_icon";
    };

    ".config/eww/scripts/bar/brightness_icon" = {
      text = builtins.readFile ./bar/brightness_icon;
      executable = true;
      target = ".config/eww/scripts/bar/brightness_icon";
    };

    ".config/eww/scripts/bar/mic_icon" = {
      text = builtins.readFile ./bar/mic_icon;
      executable = true;
      target = ".config/eww/scripts/bar/mic_icon";
    };

    ".config/eww/scripts/bar/launch" = {
      text = builtins.readFile ./bar/launch;
      executable = true;
      target = ".config/eww/scripts/bar/launch";
    };

  };
}
