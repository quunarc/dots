require('nightfox').setup({
    groups = {
        nightfox = {
            NormalFloat = { bg = "#192330" },
        },

        carbonfox = {
            NormalFloat = { bg = "#161616" },
        },
    },
})

require('kanagawa').setup({
    compile = true,
    colors = {
        theme = { all = { ui = { bg_gutter = 'none' }  }}
    },
    overrides = function(colors)
        return {
            Visual = { bg = "#363646"}
            -- LineNr = { bg = "#1f1f28" },
            -- NormalFloat = { bg = "#1f1f28" },
            -- GitSignsAdd = { bg = "#1f1f28" },
        }
    end,
})

-- local palette = require('nightfox.palette').load("nightfox")
-- print(vim.inspect(palette.bg1))

-- vim.cmd("colorscheme kanagawa")
vim.cmd("colorscheme vague")
