return {
    -- Core LSP configuration plugin
    "neovim/nvim-lspconfig",

    -- All supporting plugins used for LSP, formatting, completion, etc.
    dependencies = {
        "stevearc/conform.nvim",             -- Formatter manager
        "williamboman/mason.nvim",           -- UI for installing LSP servers
        "williamboman/mason-lspconfig.nvim", -- Bridge between mason and lspconfig
        "hrsh7th/cmp-nvim-lsp",              -- Completion source for LSP
        "hrsh7th/cmp-buffer",                -- Completion source for text in current buffer
        "hrsh7th/cmp-path",                  -- Completion source for file paths
        "hrsh7th/cmp-cmdline",               -- Completion source for command-line
        "hrsh7th/nvim-cmp",                  -- Main completion engine
        "L3MON4D3/LuaSnip",                  -- Snippet engine
        "saadparwaiz1/cmp_luasnip",          -- Completion source for LuaSnip snippets
        "j-hui/fidget.nvim",                 -- Shows LSP progress/status in UI
    },

    config = function()
        ---------------------------------------------------------------------
        -- 🧹 Formatter setup (Conform)
        ---------------------------------------------------------------------
        require("conform").setup({
            formatters_by_ft = {
                -- Add formatters per filetype here later, e.g.:
                -- lua = { "stylua" },
                -- go = { "gofmt" },
            }
        })

        ---------------------------------------------------------------------
        -- 🔧 Setup LSP Capabilities for Autocompletion
        ---------------------------------------------------------------------
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")

        -- Merge Neovim's native capabilities with cmp's enhanced capabilities
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        ---------------------------------------------------------------------
        -- 🪄 Setup helper plugins
        ---------------------------------------------------------------------
        require("fidget").setup({}) -- Shows LSP progress/loading notifications
        require("mason").setup()    -- Initializes Mason package manager

        ---------------------------------------------------------------------
        -- 🧠 Configure Mason-LSP bridge
        ---------------------------------------------------------------------
        require("mason-lspconfig").setup({
            ensure_installed = { -- Automatically install these language servers
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "tailwindcss",
                "stylua",
            },

            handlers = {
                -----------------------------------------------------------------
                -- Default handler for any LSP that doesn’t have custom config
                -----------------------------------------------------------------
                function(server_name)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities, -- Include completion support
                    }
                end,

                -----------------------------------------------------------------
                -- Custom configuration for Zig Language Server (zls)
                -----------------------------------------------------------------
                zls = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"), -- Detect project root
                        settings = {
                            zls = {
                                enable_inlay_hints = true, -- Show type hints inline
                                enable_snippets = true,    -- Enable snippet completions
                                warn_style = true,         -- Style warnings
                            },
                        },
                    })

                    -- Disable Zig autoformatter to use conform.nvim or manual formatting
                    -- vim.g.zig_fmt_parse_errors = 0
                    -- vim.g.zig_fmt_autosave = 0
                end,

                -----------------------------------------------------------------
                -- Custom configuration for Lua LSP (lua_ls)
                -----------------------------------------------------------------
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                format = {
                                    enable = true,              -- Enable LSP formatting
                                    defaultConfig = {
                                        indent_style = "space", -- Use spaces instead of tabs
                                        indent_size = "2",      -- Two spaces per indent
                                    },
                                },
                            },
                        },
                    }
                end,

                -----------------------------------------------------------------
                -- Custom configuration for TailwindCSS LSP
                -----------------------------------------------------------------
                ["tailwindcss"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.tailwindcss.setup({
                        capabilities = capabilities,
                        -- Only run TailwindCSS LSP on these filetypes
                        filetypes = {
                            "html", "css", "scss", "javascript", "javascriptreact",
                            "typescript", "typescriptreact", "vue", "svelte", "heex",
                        },
                    })
                end,
            },
        })

        ---------------------------------------------------------------------
        -- 💬 nvim-cmp (Autocompletion setup)
        ---------------------------------------------------------------------
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                -- Tell nvim-cmp how to expand snippets
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },

            -- Key mappings for completion navigation
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select), -- previous suggestion
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select), -- next suggestion
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),   -- confirm selection
                ["<C-Space>"] = cmp.mapping.complete(),               -- manually trigger completion
            }),

            -- Define completion sources (in priority order)
            sources = cmp.config.sources({
                { name = "copilot", group_index = 2 }, -- GitHub Copilot (if installed)
                { name = 'nvim_lsp' },                 -- LSP suggestions
                { name = 'luasnip' },                  -- Snippet completions
            }, {
                { name = 'buffer' },                   -- Words from current buffer
            }),
        })

        ---------------------------------------------------------------------
        -- ⚠️ Diagnostic settings (for error/warning popups)
        ---------------------------------------------------------------------
        vim.diagnostic.config({
            -- Controls how diagnostics (like errors/warnings) are displayed
            float = {
                focusable = false,
                style = "minimal",  -- simple style (no clutter)
                border = "rounded", -- rounded popup borders
                source = "always",  -- always show the source (e.g. LSP name)
                header = "",        -- no header text
                prefix = "",        -- no bullet prefix
            },
        })
    end,
}
