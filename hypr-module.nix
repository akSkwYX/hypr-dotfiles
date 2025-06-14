{ pkgs, config, ... }:
{
  imports = [
    ./conf/hypr/scripts/scripts.nix
    ./conf/rofi/scripts/scripts.nix
    ./conf/eww/scripts/scripts.nix
    ./conf/quickshell/scripts/scripts.nix
  ];

  # Dependencies :
  home.packages = with pkgs; [
    hyprpaper
    hyprlock
    hypridle
    curl
    jq
    app2unit
    fd
    python313.withPackages (ps: with ps; [
      aubio
      pyaudio
      numpy
    ])
    cava
    networkmanager
    bluez
    ddcutil
    brightnessctl
    imagemagick
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

    ".config/quickshell" = {
      source = ./conf/quickshell/confFiles;
      recursive = true;
    };
  };
}
