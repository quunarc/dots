local my_config_path = _G.NIX_CONFIG_PATH
local lazy_plugin_path = _G.NIX_LAZY_PATH

-- 1. Setup paths using the Nix Store path
vim.opt.rtp:prepend(my_config_path)

package.path = package.path .. ";" .. my_config_path .. "/?.lua"
package.path = package.path .. ";" .. my_config_path .. "/?/init.lua"

require("lazy").setup({
    dev = {
        path = lazy_plugin_path,
        patterns = { "" },
        fallback = true,
    },
    spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- Nix-specific fixes
        { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
        { "mason-org/mason.nvim", enabled = false },
        { "mason-org/mason-lspconfig.nvim", enabled = false },
        -- Import your local plugins
        { import = "plugins" },
    },
})
