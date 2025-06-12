{
  description = "My Hypr environment configuration as a flake module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, hyprland, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    hyprpkg = hyprland.packages."${system}".hyprland;
  in {
    homeModules.default = import ./hypr-module.nix;

    hyprpkg = hyprpkg;

    devShells.default.hypr = pkgs.mkShell {
      buildInputs = [
        hyprpkg
        pkgs.hyprpaper
        pkgs.hyprlock
        pkgs.hypridle
        pkgs.eww
        pkgs.alsa-utils
        pkgs.libnotify
        pkgs.swaynotificationcenter
        pkgs.rofi-wayland
        pkgs.brightnessctl
        pkgs.playerctl
      ];
      shellHook = ''
        echo "Entered HyprTest shell"
        echo "Config root : $HOME/.test"
        echo "Real config : $HOME/.config"
        export XDG_CONFIG_HOME="$HOME/.test"
        mkdir -p "$XDG_CONFIG_HOME"/{hypr,rofi,eww}
      '';
    };
  };
}
