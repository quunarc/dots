{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # external
    csharplsp = {
        url = "github:SofusA/csharp-language-server";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    kwin-effects-glass = {
        url = "github:4v3ngR/kwin-effects-glass";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    kwin-effects-better-blur-dx = {
      url = "github:xarblu/kwin-effects-better-blur-dx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen = {
        url = "github:0xc000022070/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    my-nvim.url = "path:/home/quun/.dotfiles/dots/NixvimLazyvim";
    nvim-custom.url = "/home/quun/Softwares/NvimCustom/";

    nix-alien.url = "github:thiagokokada/nix-alien";

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

