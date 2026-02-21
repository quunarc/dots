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
                omnisharp = {
            -- Nix usually wraps the binary, so we call it directly
                    cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },

                    -- Force an absolute path for the root
                    root_dir = function(fname)
                    local util = require("lspconfig.util")
                    local root = util.root_pattern("*.sln", "*.csproj", "project.godot")(fname)
                                or vim.fn.getcwd()
                    return vim.fn.fnamemodify(root, ":p")
                    end,

                    -- Nix specific: Ensure the server knows where the SDK is
                    on_new_config = function(new_config, new_root_dir)
                    new_config.env = new_config.env or {}
                    -- You might need to check your actual nix store path for this
                    -- but usually 'dotnet' being in PATH is enough.
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
