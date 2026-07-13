{
  description = "NixOS configuration with Hyprland";

  inputs = {
    nixpkgs.url = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    openclaw-workspace = {
      url = "path:/home/vokrob/.config/openclaw";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, nix-openclaw, openclaw-workspace, ... }@inputs: {
    nixosConfigurations.vokrob = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit nix-openclaw openclaw-workspace; };
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        ./hosts/nixos
      ];
    };
  };
}
