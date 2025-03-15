{ inputs, ... }:

let
  system = "x86_64-linux"; # Change this to your system architecture if needed
  
in {
  testmachine = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      # Core NixOS configuration
      {
        system.stateVersion = "23.11";
        
        networking.hostName = "testmachine";
        
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        
        users.users.testuser = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          initialPassword = "changeme";
        };
        
        environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
          git
          vim
          wget
        ];
      }
      
      # Include home-manager as a NixOS module
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.testuser = {
          home.stateVersion = "23.11";
          home.packages = with inputs.nixpkgs.legacyPackages.${system}; [
            htop
            ripgrep
          ];
        };
      }
    ];
  };
}
