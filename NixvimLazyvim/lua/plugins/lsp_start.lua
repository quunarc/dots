return {
    { "mason-org/mason-lspconfig.nvim", enabled = false },
    { "mason-org/mason.nvim",           enabled = false },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                nixd = {},
                rust_analyzer = {},
                clangd = {},
                lua_ls = {},
                asm_lsp = {},
                pyright = {},
                -- glslls = {},
            },
            inlay_hints = { enabled = false },
        },
    },
}
