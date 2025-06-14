{ pkgs, config, ... }:
let python_dependencies = pkgs.python313.withPackages (ps: with ps; [
      matplotlib
      aubio
      pyaudio
      numpy
    ]);
in
{
  imports = [
    ./conf/hypr/scripts/scripts.nix
    ./conf/rofi/scripts/scripts.nix
    ./conf/eww/scripts/scripts.nix
    ./conf/quickshell/scripts/scripts.nix
  ];

  # Dependencies :
  home.packages = [
    pkgs.hyprpaper
    pkgs.hyprlock
    pkgs.hypridle
    pkgs.curl
    pkgs.jq
    pkgs.ibm-plex
    pkgs.app2unit
    pkgs.fd
    pkgs.cava
    pkgs.networkmanager
    pkgs.bluez
    pkgs.ddcutil
    pkgs.brightnessctl
    pkgs.imagemagick
    pkgs.material-symbols
    python_dependencies
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
