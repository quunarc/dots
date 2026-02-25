local my_config_path = _G.NIX_CONFIG_PATH
local lazy_plugin_path = _G.NIX_LAZY_PATH

-- Override the config path to prevent looking in ~/.config/nvim
vim.cmd('set runtimepath^=' .. _G.NIX_CONFIG_PATH)
vim.cmd('set runtimepath+=/etc/xdg/nvim') -- or whatever you need

-- Remove the default config path if it exists
local default_config = vim.fn.expand('~/.config/nvim')
if vim.fn.isdirectory(default_config) == 1 then
    vim.opt.rtp:remove(default_config)
end

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

-- -- 3. NOW you can require them
require("config.theme-conf")
require("config.godot-nvim")
require("config.qol")
require("config.lua_snippets")

 -- -- 2. Load your LIVE init.lua from your disk
 -- -- This makes your changes to init.lua instant!
 -- local live_init = _G.LIVE_CONFIG_PATH .. "/init.lua"
 --
 -- if vim.fn.filereadable(live_init) == 1 then
 --     dofile(live_init)
 -- end
