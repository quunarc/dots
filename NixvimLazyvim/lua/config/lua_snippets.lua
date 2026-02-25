-- luasnip.lua

print("LUASNIP CONFIG LOADED!")
local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node

ls.add_snippets("all", {
    s("hmod", fmt([[
    // ---------------------- {} ---------------------------
    // -----------------------------------------------------
    {}
        ]], {
            i(1, "Model"), -- The placeholder ${1:Model}
            i(0)           -- The final cursor position $0
        }))
})
