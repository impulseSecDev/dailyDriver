{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    osc = {
      url = "path:/home/tim/OSC";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs@{ nixpkgs, sops-nix, nixpkgs-xr, home-manager, osc, ... }: {
    nixosConfigurations.PlayWasHere = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        sops-nix.nixosModules.sops
        nixpkgs-xr.nixosModules.nixpkgs-xr
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.tim = import /home/tim/.config/home-manager/home.nix;
          home-manager.extraSpecialArgs = { inherit osc; };
        }
      ];
    };
  };
}
