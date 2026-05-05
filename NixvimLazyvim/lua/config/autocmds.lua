-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- CHANGE DIRECTORY TO PROJECT DIRECTORY
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

-- REMOVE TRAILING WHITE SPACE ON SAVE
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

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function()
        vim.keymap.set("t", "<C-S-.>", "<C-\\><C-n>", { buffer = 0 })
    end,
})


-- OMNISHARP IS A BITCH SO START IT MANUALLY
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cs",
  callback = function()
    local lspconfig = require("lspconfig")
    local root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", "project.godot")(vim.api.nvim_buf_get_name(0))
    root_dir = root_dir or vim.fn.getcwd()
    local absolute_root = vim.fn.fnamemodify(root_dir, ":p")

    lspconfig.omnisharp.setup({
      cmd = { "OmniSharp", "--languageserver" },
      root_dir = absolute_root,
      -- This matches the host PID so OmniSharp closes when Neovim does
      on_new_config = function(new_config, new_root_dir)
        table.insert(new_config.cmd, "--hostPID")
        table.insert(new_config.cmd, tostring(vim.fn.getpid()))
      end,
    })

    vim.cmd("LspStart omnisharp")
  end,
})

-- ENABLE INLAY HINTS FOR NIX FILES
vim.api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = function()
    vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
  end,
})
