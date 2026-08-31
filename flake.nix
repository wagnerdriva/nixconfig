{
  description = "NixOS configuration for Wagner's Dell Precision 5530";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # A pinned visual reference. We only reuse the wallpaper; the configuration
    # itself lives in this repository and can evolve independently.
    ramos-config = {
      url = "github:ramosrafh/nixconfig/f7dcdf28a83f7c5b676f554c66fc6f3c969d8528";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, disko, niri-flake, ... }:
    let
      system = "x86_64-linux";
      primaryUser = "wagner";
    in {
      nixosConfigurations.precision = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs primaryUser; };

        modules = [
          ./hosts/precision
          disko.nixosModules.disko
          niri-flake.nixosModules.niri
          home-manager.nixosModules.home-manager

          {
            nixpkgs.overlays = [ niri-flake.overlays.niri ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users.${primaryUser} = import ./modules/home;
              extraSpecialArgs = { inherit inputs primaryUser; };
            };
          }
        ];
      };

      packages.${system}.disko = disko.packages.${system}.disko;
    };
}
