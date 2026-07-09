
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
        -- config = function ()
        --     require("noctishc").setup()
        --     vim.cmd("colorscheme vague")
        -- end
    },
    { "arturgoms/moonbow.nvim" },
    { "EdenEast/nightfox.nvim" },

  -- Configure LazyVim to load gruvbox
    { "rebelot/kanagawa.nvim" },
    { "Kalidozza-theme/neovim" },
    { "sainnhe/everforest" },
    { "slugbyte/lackluster.nvim" },
    { "thesimonho/kanagawa-paper.nvim" },
    { "romainl/Apprentice" },
    { "vague-theme/vague.nvim" },
    { "water-sucks/darkrose.nvim" },
    { "nyoom-engineering/oxocarbon.nvim" },
    { "marko-cerovac/material.nvim" },
}
