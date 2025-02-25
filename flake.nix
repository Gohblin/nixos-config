{
  description = "Joshua's NixOS Configuration";

  inputs = {
    # Core inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    
    # Zen browser flake
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    
    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixcord.url = "github:kaylorben/nixcord";
    nvf.url = "github:NotAShelf/nvf";


    # TODO: Add hardware configuration if needed
    # hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, nixcord, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      reddit-tui = pkgs.callPackage /home/joshua/nixos-config/packages/reddit-tui.nix { };
    };

    nixosConfigurations = {
      # TODO: Replace 'hostname' with your actual hostname
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.joshua = import ./home-manager/default.nix;
            
             home-manager.sharedModules = [
              inputs.nixcord.homeManagerModules.nixcord
            ];
 

            
 
            # Pass flake inputs to home-manager configuration
            home-manager.extraSpecialArgs = {
              inherit inputs zen-browser;
            };
          }
        ];
        
        # Pass flake inputs to NixOS configuration
        specialArgs = { inherit inputs; };
      };
    };


    homeConfigurations = {
      "joshua@nixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/default.nix
          {
            # Zen-browser configuration
            home.packages = [ zen-browser.packages.${system}.default ];
          }
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };

    # Expose modules from subdirectories
    nixosModules = import ./nixos/modules;
    homeManagerModules = import ./home-manager/modules;

    # TODO: Add any custom packages or overlays
    # overlays = import ./overlays;
  };
}
