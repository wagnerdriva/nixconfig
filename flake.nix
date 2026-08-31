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
  };

  outputs = { nixpkgs, home-manager, disko, niri-flake, ... }:
    let
      system = "x86_64-linux";
      primaryUser = "wagner";
    in {
      nixosConfigurations.precision = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit primaryUser; };

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
              extraSpecialArgs = { inherit primaryUser; };
            };
          }
        ];
      };

      packages.${system}.disko = disko.packages.${system}.disko;
    };
}
