{
  description = "NixOS configuration for Wagner's machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    ai-memory.url = "github:akitaonrails/ai-memory";

    herdr.url = "github:herdrdev/herdr";

    query-on = {
      url = "git+https://github.com/ramosrafh/query-on?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
    };

  };

  outputs = { nixpkgs, home-manager, disko, niri-flake, ai-memory, dms, herdr, query-on, ... }:
    let
      system = "x86_64-linux";
      primaryUser = "wagner";

      mkConfiguration = { host, hostName, minimalAgentSetup ? false }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit primaryUser hostName minimalAgentSetup; };

          modules = [
            host
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
                extraSpecialArgs = {
                  inherit primaryUser hostName;
                  aiMemoryPackage = if minimalAgentSetup then null else
                    ai-memory.packages.${system}.default;
                  herdrPackage = herdr.packages.${system}.default;
                  herdrPiExtension = "${herdr}/src/integration/assets/pi/herdr-agent-state.ts";
                  queryOnPackage = if minimalAgentSetup then null else
                    query-on.packages.${system}.default;
                  inherit minimalAgentSetup;
                  inherit dms;
                };
              };
            }
          ];
        };
    in {
      nixosConfigurations = {
        precision = mkConfiguration {
          host = ./hosts/precision;
          hostName = "precision";
        };
        zenbook = mkConfiguration {
          host = ./hosts/zenbook;
          hostName = "zenbook";
        };
        ryzen = mkConfiguration {
          host = ./hosts/ryzen;
          hostName = "ryzen";
          minimalAgentSetup = true;
        };
      };

      packages.${system}.disko = disko.packages.${system}.disko;
    };
}
