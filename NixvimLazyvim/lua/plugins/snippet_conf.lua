return {
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
    config = function(plugin, opts)
      -- This runs the default LazyVim setup
      require("luasnip").setup(opts)

      -- This tells LuaSnip to look at your custom snippets folder
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
    end,
  },
}
