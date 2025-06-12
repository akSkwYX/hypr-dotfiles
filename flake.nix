{
  description = "My Hypr environment configuration as a flake module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, hyprland, ... }: {
    hyprpkg = hyprland.packages."x86_64-linux".hyprland;
    homeModules.default = import ./hypr-module.nix;
  };
}
