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
    ./conf/hypr/hypr.nix
    ./conf/quickshell/quickshell.nix
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
    pkgs.libnotify
    python_dependencies
  ];

  home.sessionVariables = {
    XDG_SESSION_DESKTOP = "Hyprland";
  };
}
