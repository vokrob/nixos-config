{
  description = "NixOS configuration with Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-blender.url = "github:NixOS/nixpkgs/nixos-25.05";
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

  outputs = {
    self,
    nixpkgs,
    nixpkgs-blender,
    home-manager,
    agenix,
    nix-openclaw,
    openclaw-workspace,
    ...
  } @ inputs: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations.vokrob = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit nix-openclaw openclaw-workspace;};
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        {
          nixpkgs.overlays = [
            (final: prev: {
              blender_4 = nixpkgs-blender.legacyPackages.${final.stdenv.hostPlatform.system}.blender;
            })
          ];
        }
        ./hosts/nixos
      ];
    };
  };
}
