{
    description = "Setup LazyVim using NixVim";

    inputs = {
        nixpkgs = {
            url = "github:NixOS/nixpkgs/nixos-unstable";
        };
        nixvim = {
            url = "github:nix-community/nixvim";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.flake-parts.follows = "flake-parts";
        };
        flake-parts = {
            url = "github:hercules-ci/flake-parts";
            inputs.nixpkgs-lib.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, nixvim, flake-parts } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
    ];

    perSystem = { pkgs, lib, system, ... }:
    let
        config = {
        # Reduce closure size
        enableMan = false;
        withPython3 = false;
        withRuby = false;

        extraPackages = with pkgs; [
            # LazyVim
            lua-language-server
            clang-tools
            stylua
            # Telescope
            ripgrep
            tree-sitter
            omnisharp-roslyn
            dotnet-sdk
            astro-language-server
            typescript-language-server
            tailwindcss-language-server
            typescript
            gopls
            rust-analyzer
            glsl_analyzer
        ];

        extraPlugins = [ pkgs.vimPlugins.lazy-nvim ];

        extraConfigLua =
            let
            plugins = with pkgs.vimPlugins; [
                # LazyVim
                LazyVim
                bufferline-nvim
                cmp-buffer
                cmp-nvim-lsp
                cmp-path
                conform-nvim
                dashboard-nvim
                dressing-nvim
                flash-nvim
                friendly-snippets
                gitsigns-nvim
                grug-far-nvim
                indent-blankline-nvim
                lazydev-nvim
                lualine-nvim
                luvit-meta
                neo-tree-nvim
                noice-nvim
                nui-nvim
                nvim-cmp
                nvim-lint
                nvim-lspconfig
                nvim-snippets
                nvim-treesitter
                nvim-treesitter-textobjects
                nvim-ts-autotag
                persistence-nvim
                plenary-nvim
                snacks-nvim
                telescope-fzf-native-nvim
                telescope-nvim
                todo-comments-nvim
                tokyonight-nvim
                trouble-nvim
                ts-comments-nvim
                which-key-nvim
                toggleterm-nvim
                vim-wakatime
                { name = "catppuccin"; path = catppuccin-nvim; }
                { name = "mini.ai"; path = mini-nvim; }
                { name = "mini.icons"; path = mini-nvim; }
                { name = "mini.pairs"; path = mini-nvim; }
            ];
            mkEntryFromDrv = drv:
                if lib.isDerivation drv then
                { name = "${lib.getName drv}"; path = drv; }
                else
                drv;
            lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
            myConfig = ./lua;
            projectPath = ".";
            in
            ''
            -- Inject the Nix store paths into global Lua variables
            _G.NIX_CONFIG_PATH = "${myConfig}"
            _G.NIX_LAZY_PATH = "${lazyPath}"
            _G.LIVE_CONFIG_PATH = "${projectPath}" -- Pass the "Live" path to Lua

            -- Load the external Lua file
            ${builtins.readFile ./lua/init-nix.lua}
            '';
        };
        nixvim' = nixvim.legacyPackages."${system}";
        nvim = nixvim'.makeNixvim config;
        nvim-pkg = nixvim'.makeNixvim config;
    in
    {
        packages = {
            default = nvim-pkg;
            nvim = nvim-pkg;
        };
    };
    };
}
