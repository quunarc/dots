require('nightfox').setup({
    groups = {
        nightfox = {
            -- This makes the highlight a very subtle dark blue-grey
            -- Matches the explorer background to the editor background
            NormalFloat = { bg = "#192330" },

            -- Optional: Matches the input/search bar at the top
            SnacksInputNormal = { bg = "palette.bg1" },

            -- Optional: Cleans up the vertical split line if it's annoying
            SnacksExplorerWinSeparator = { fg = "palette.bg0", bg = "palette.bg1" },
            -- Optional: Make the line number stand out so you don't lose your place
            -- CursorLineNr = { fg = "palette.blue", bold = true },
        },

        carbonfox = {
            -- This makes the highlight a very subtle dark blue-grey
            -- Matches the explorer background to the editor background
            NormalFloat = { bg = "#161616" },
        },
    },
    palettes = {
        -- Custom duskfox with black background
        nightfox = {
        bg1 = "#192330", -- Black background
        -- bg0 = "#192330", -- Alt backgrounds (floats, statusline, ...)
        -- bg3 = "#121820", -- 55% darkened from stock
        -- sel0 = "#131b24", -- 55% darkened from stock
        },
    },
})

-- local palette = require('nightfox.palette').load("nightfox")
-- print(vim.inspect(palette.bg1))

vim.cmd("colorscheme nightfox")
