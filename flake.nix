{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # # external
    # csharplsp = {
    #     url = "github:SofusA/csharp-language-server";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };

    # kwin-effects-glass = {
    #     url = "github:4v3ngR/kwin-effects-glass";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };

    # kwin-glass-x11 = {
    #     url = "github:4v3ngR/kwin-effects-glass/0ae94cf5e709a894a9f1f54544cb17deb7f77d58";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };

    # kwin-effects-better-blur-dx = {
    #   url = "github:xarblu/kwin-effects-better-blur-dx";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    kwin-effects-forceblur = {
      url = "github:can1357/kde-blur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen = {
        url = "github:0xc000022070/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    my-nvim.url = "path:./NixvimLazyvim";
    # nvim-custom.url = "path:./NvimCustom/";

    nix-alien.url = "github:thiagokokada/nix-alien";

  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
       system = "x86_64-linux";
       systems = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
        ./configuration.nix
        #
        # home-manager.nixosModules.home-manager
        #
        # {
        #     home-manager.useGlobalPkgs = true;
        #     home-manager.useUserPackages = true;
        #
        #     home-manager.users.quun = import ./home.nix;
        #
        #     home-manager.extraSpecialArgs = {
        #     inherit inputs;
        #     };
        # }
        ];

        specialArgs = {
            inherit inputs;
        };
      };

      homeConfigurations.quun = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config = { allowUnfree = true; }; };
        modules = [ ./home.nix ];
	    extraSpecialArgs = { inherit self system systems nixpkgs home-manager inputs; };
      };
    };
}

