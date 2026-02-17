{
  description = "Setup LazyVim using NixVim";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixvim.url = "github:nix-community/nixvim";
  inputs.nixvim.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixvim.inputs.flake-parts.follows = "flake-parts";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

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
              in
              ''
                local home = os.getenv("HOME")
                local config_path = home .. "/.config/nvim"

                -- 1. Setup paths so Lua can find your files
                vim.opt.rtp:prepend(config_path)
                package.path = package.path .. ";" .. config_path .. "/lua/?.lua"

                require("lazy").setup({
                    dev = {
                    path = "${lazyPath}",
                    patterns = { "" },
                    fallback = true,
                    },
                    spec = {
                    -- Load LazyVim core
                    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

                    -- Nix-specific fixes
                    { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
                    { "williamboman/mason.nvim", enabled = false },
                    { "williamboman/mason-lspconfig.nvim", enabled = false },

                    -- 2. TRY THIS: Explicitly point to the directory
                    -- If 'import = "plugins"' fails, this is the manual way:
                    { dir = config_path .. "/lua/plugins", import = "plugins" },
                    },
                })
              '';
          };
          nixvim' = nixvim.legacyPackages."${system}";
          nvim = nixvim'.makeNixvim config;
        in
        {
          packages = {
            inherit nvim;
            default = nvim;
          };
        };
    };
}
