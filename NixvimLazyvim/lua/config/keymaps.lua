-- Keyvim.keymap.sets are automatically loaded on the VeryLazy event
-- Default keyvim.keymap.sets that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keyvim.keymap.sets.lua
-- Add any additional keyvim.keymap.sets here
local map = vim.keymap.set

-- Map F5 to run OverseerRun in normal mode
vim.keymap.set("n", "<F5>", "<cmd>OverseerRun<CR>", { desc = "Run Overseer Task" })

-- Move in insert mode using Ctrl + H/J/K/L
map("i", "<C-h>", "<Left>", { desc = "Move Left in Insert Mode" })
map("i", "<C-j>", "<Down>", { desc = "Move Down in Insert Mode" })
map("i", "<C-k>", "<Up>", { desc = "Move Up in Insert Mode", noremap = true })
map("i", "<C-l>", "<Right>", { desc = "Move Right in Insert Mode" })

map("n", "<Space>fq", "<cmd>ToggleTerm direction=float<CR>", { noremap = true, silent = true })

-- ALT+arrowkeys to move lines up or down, just like you do in VSCode
map("n", "<A-Up>", ":m .-2<CR>==", { noremap = true, silent = true })  -- Move line up
map("n", "<A-Down>", ":m .+1<CR>==", { noremap = true, silent = true }) -- Move line down
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true }) -- Move selection up
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true }) -- Move selection down
