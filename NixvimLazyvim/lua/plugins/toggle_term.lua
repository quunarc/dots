return {

    {'akinsho/toggleterm.nvim',
        version = "*",
        config = function ()
            require("toggleterm").setup({
                float_opts = {
                    border = "curved",
                    width = function ()
                        return math.floor(vim.o.columns * 0.95)
                    end,
                    heigh = function ()
                        return math.floor(vim.o.lines * 0.95)
                    end,
                }
            })
        end
    }

}
