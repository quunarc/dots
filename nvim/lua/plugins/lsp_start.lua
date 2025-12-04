return {
    { "mason-org/mason-lspconfig.nvim", enabled = false },
    { "mason-org/mason.nvim",           enabled = false },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                nixd = {},
                clangd = {},
                lua_ls = {},
                asm_lsp = {},
                pyright = {},
            },
        },
    },
}
