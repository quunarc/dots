local map = vim.keymap.set
local themes = { "ayu-dark", "noctishc" }  -- Make sure you use "noctishc" correctly
local current_theme = 2

function ToggleTheme()
    current_theme = 3 - current_theme  -- Toggles between 1 and 2
    vim.cmd("colorscheme " .. themes[current_theme])
    vim.g.current_theme = current_theme  -- Save state
    vim.notify("Switched to " .. themes[current_theme], vim.log.levels.INFO)
end

vim.keymap.set("n", ".", ToggleTheme, { noremap = true, silent = true, desc = "Toggle Theme" })

vim.cmd [[
  highlight WhichKey guibg=NONE
  highlight WhichKeyFloat guibg=NONE
  highlight WhichKeyBorder guibg=NONE
  highlight WhichKeySeparator guibg=NONE
  highlight Special guibg=NONE
  highlight SnacksDashboardDesc guibg=NONE
]]

-- local Util = require("lazyvim.util")
--
-- Override LazyVim's root detection function to include CMakeLists.txt
-- function Util.root.get(path, patterns)
--     patterns = patterns or { ".git", "CMakeLists.txt", "Makefile", "build" } -- Add CMake files
--     return require("lazyvim.util.root").find(path or vim.fn.getcwd(), patterns)
-- end

vim.api.nvim_create_user_command("Search", function (opts)

    local args = vim.split(opts.args, " ")

    if #args < 2 then return end

    local search = vim.fn.escape(args[1], '\\/')
    local replace = args[2]

    vim.cmd('%s/\\<'..search..'\\>/'..replace..'/g')

end, {nargs="*"})
