{
description = "My nix config flake";
inputs = {
nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
};
outputs = {self, nixpkgs}:
let
system = "x86_64-linux";
pkgs = import nixpkgs {
inherit system;
conifg = {
allowUnfree = true;
};
};
in
{
nixosConfigurations = {
m42 = nixpkgs.lib.nixosSystem {
specialArgs = {inherit system;};
modules = [./configuration.nix];
};
};
};
}
