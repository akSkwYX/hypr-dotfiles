{ pkgs, config, ... }:
{
  imports = [
    ./conf/hypr/scripts/scripts.nix
    ./conf/rofi/scripts/scripts.nix
    ./conf/eww/scripts/scripts.nix
  ];

  # Dependencies :
  home.packages = with pkgs; [
    hyprpaper
    hyprlock
    hypridle
    eww
    alsa-utils
    libnotify
    swaynotificationcenter
    rofi-wayland
    brightnessctl
    playerctl
  ];

  home.file = {
    ".config/hypr" = {
      source = ./conf/hypr/confFiles;
      recursive = true;
    };

    ".config/rofi" = {
      source = ./conf/rofi/confFiles;
      recursive = true;
    };

    ".config/eww" = {
      source = ./conf/eww/confFiles;
      recursive = true;
    };
  };
}
