{
  description = "My Hypr environment configuration as a flake module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, hyprland, ... }: {
    hyprpkg = hyprland.packages."${system}".hyprland;
    homeModules.default = import ./hypr-module.nix;
  };
}
