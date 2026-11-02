{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05"; #/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";

    flake-utils.url = "github:numtide/flake-utils";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    strata-src = { url = "github:Niko1221/Strata"; flake = false; };
    # Must be the exact commit Strata pins (check CMakeLists.txt / setup.py LLAMA_CPP_COMMIT)
    llama-src = {
      url = "github:ggml-org/llama.cpp/3cf03257f219afbe7334045ff7c6a06ac68c627d";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, sops-nix, home-manager, nixvim, lanzaboote, disko, ... }: {
    nixosConfigurations.PlayWasHere = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        sops-nix.nixosModules.sops
        nixvim.nixosModules.nixvim 
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        lanzaboote.nixosModules.lanzaboote
        ./disko-config.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.tim = import ./home.nix;
          #home-manager.extraSpecialArgs = { inherit osc; };
        }
      ];
    };
  };
}
