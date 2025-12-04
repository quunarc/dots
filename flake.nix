{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # external
    zen.url = "github:0xc000022070/zen-browser-flake";
    csharplsp.url = "github:SofusA/csharp-language-server";
	#    lazyvim = {
	# url = "github:pfassina/lazyvim-nix";
	# inputs.nixpkgs.follows = "nixpkgs";
	#    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
       systems = "x86_64-linux";
    in
    {
      homeConfigurations.quun = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config = { allowUnfree = true; }; };
        modules = [ ./home.nix ];
	    extraSpecialArgs = { inherit self systems nixpkgs home-manager inputs; };
      };
    };
}

