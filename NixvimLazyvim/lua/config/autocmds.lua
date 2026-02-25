-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local root = vim.fn.getcwd() -- Default to current directory
        -- Use LazyVim's root finder to detect the project root
        local new_root = require("lazyvim.util").root.get()
        if new_root and root ~= new_root then
            vim.cmd("cd " .. new_root) -- Change directory
        end
    end,
})

-- vim.api.nvim_set_hl(0, 'Normal', { bg = '#0000FF', italic = true })

-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = 'cs',
--   callback = function(args)
--     local root_dir = vim.fs.dirname(
--       vim.fs.find({ '.sln', '.slnx', '.csproj', '.git' }, { upward = true })[1]
--     )
--     vim.lsp.start({
--       name = 'csharp-language-server',
--       cmd = {'csharp-language-server'},
--       root_dir = root_dir,
--     })
--   end,
-- })

-- Remove trailing white space on save
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Removes trailing whitespace on save",
  pattern = "*", -- Apply to all file types
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    pcall(function()
      vim.cmd [[%s/\s\+$//e]]
    end)
    vim.fn.setpos('.', save_cursor)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "cs",
  callback = function()
    local lspconfig = require("lspconfig")

    -- 1. Find the root project folder (looking for .sln or .csproj)
    local root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", "project.godot")(vim.api.nvim_buf_get_name(0))

    -- 2. Fallback to current working directory if no project file found
    root_dir = root_dir or vim.fn.getcwd()

    -- 3. Convert to ABSOLUTE path (crucial for the error you saw)
    local absolute_root = vim.fn.fnamemodify(root_dir, ":p")

    -- 4. Manually trigger OmniSharp with the absolute path
    lspconfig.omnisharp.setup({
      cmd = { "OmniSharp", "--languageserver" },
      root_dir = absolute_root,
      -- This matches the host PID so OmniSharp closes when Neovim does
      on_new_config = function(new_config, new_root_dir)
        table.insert(new_config.cmd, "--hostPID")
        table.insert(new_config.cmd, tostring(vim.fn.getpid()))
      end,
    })

    -- Force start for this specific buffer
    vim.cmd("LspStart omnisharp")
  end,
})

-- vim.api.nvim_create_autocmd("BufEnter", {
--     callback = function()
--         local Util = require("lazyvim.util")
--         local patterns = { ".git", "CMakeLists.txt", "Makefile", "build" } -- Add CMake files
--         local new_root = Util.root.get(vim.fn.expand("%:p"), patterns) -- Pass current file
--
--         if new_root and vim.fn.getcwd() ~= new_root then
--             vim.cmd("cd " .. vim.fn.fnameescape(new_root))
--             vim.notify("Changed directory to: " .. new_root, vim.log.levels.INFO)
--         else
--             vim.notify("No project root detected for: " .. vim.fn.expand("%:p"), vim.log.levels.WARN)
--         end
--     end,
-- })
--
