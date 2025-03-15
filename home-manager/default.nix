{ inputs, ... }:

let
  system = "x86_64-linux"; # Change to your system architecture if needed
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  
in {
  testuser = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      {
        home = {
          username = "testuser";
          homeDirectory = "/home/testuser";
          stateVersion = "23.11";
          
          packages = with pkgs; [
            htop
            ripgrep
            fd
          ];
        };
        
        programs.home-manager.enable = true;
        
        programs.git = {
          enable = true;
          userName = "Test User";
          userEmail = "testuser@example.com";
        };
      }
    ];
  };
}
