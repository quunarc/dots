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
                asm_lsp = {},
                pyright = {},
                html = {},
                astro = {},
                tailwindcss = {},
                gopls = {},
                -- glslls = {},
                --
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = {
                                    "vim",
                                }
                            },
                        },
                    },
                },
                --
                omnisharp = {
                    cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },

                    root_dir = function(fname)
                    local util = require("lspconfig.util")
                    local root = util.root_pattern("*.sln", "*.csproj", "project.godot")(fname)
                                or vim.fn.getcwd()
                    return vim.fn.fnamemodify(root, ":p")
                    end,

                    on_new_config = function(new_config, new_root_dir)
                    new_config.env = new_config.env or {}
                    new_config.env.DOTNET_ROOT = vim.fn.trim(vim.fn.system("dirname $(which dotnet)"))
                    end,

                    settings = {
                    FormattingOptions = {
                        EnableEditorConfigSupport = false,
                        OrganizeImports = true,
                    },
                    RoslynExtensionsOptions = {
                        EnableImportCompletion = true,
                        AnalyzeOpenDocumentsOnly = false,
                    },
                    },
                },
            },
            inlay_hints = { enabled = false },
        },
    },
}
