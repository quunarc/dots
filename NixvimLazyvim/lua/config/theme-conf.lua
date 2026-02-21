require('nightfox').setup({
  groups = {
    all = {
      -- This makes the highlight a very subtle dark blue-grey
      CursorLine = { bg = "#333a47" },

      -- Optional: Make the line number stand out so you don't lose your place
      -- CursorLineNr = { fg = "palette.blue", bold = true },
    }
  }
})


vim.cmd("colorscheme vague")
