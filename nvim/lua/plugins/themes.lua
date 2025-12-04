return {
  -- add gruvbox
    { "ellisonleao/gruvbox.nvim" },
    {
        "Shatur/neovim-ayu",
        config = function()
            require("ayu").setup({
            overrides = {
                Normal = { bg = "#0e1017" },
            },
            })
        end,
    },
    {
        "iagorrr/noctishc.nvim",
        config = function ()
            require("noctishc").setup()
            vim.cmd("colorscheme noctishc")
        end
    },
    {
        "arturgoms/moonbow.nvim"
    },

  -- Configure LazyVim to load gruvbox
    { "rebelot/kanagawa.nvim" },
    { "Kalidozza-theme/neovim" },
    { "sainnhe/everforest" },
}
