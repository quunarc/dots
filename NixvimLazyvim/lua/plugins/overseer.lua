return {
    "stevearc/overseer.nvim",
    config = function()
        require("overseer").setup({
            default_strategy = { "toggleterm", direction = "float" },
        })
    end,
    opts = {},
}
