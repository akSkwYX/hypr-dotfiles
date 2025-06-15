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
    pkgs.cliphist
    pkgs.fuzzel
    pkgs.xdg-user-dirs
    pkgs.grim
    pkgs.upower
    pkgs.power-profiles-daemon
    python_dependencies
  ];

  home.file = {
    ".config/hypr" = {
      source = ./conf/hypr/confFiles;
      recursive = true;
    };

    ".config/quickshell" = {
      source = ./conf/quickshell/confFiles;
      recursive = true;
    };
  };
}
