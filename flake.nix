{
  description = "My Hypr environment configuration as a flake module";

  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, hyprland, ... }: {
    homeModules.default = import ./hypr-module.nix;
    hyprpkg = hyprland.packages."x86_64-linux".hyprland;

    devShells.default.hypr = pkgs.mkShell {
      buildInputs = [
        hyprpkg
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
