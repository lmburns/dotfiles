local M = {}

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local lspconfig = require("lspconfig")
local lsp_installer = require("nvim-lsp-installer")

local handlers = require("plugs.lsp.handlers")

local style = require("style")
local icons = style.icons.lsp
local utils = require("common.utils")
local augroup = utils.augroup

local L = vim.lsp.log_levels
local ex = nvim.ex
local fn = vim.fn
local api = vim.api

if vim.env.DEVELOPING then
    vim.lsp.set_log_level(L.DEBUG)
end

-- FIX: Show error code like E123: in popup
-- FIX: CursorHold event not registering to show popup sometimes
-- FIX: Max file issue with Lua
-- FIX: After installation, not all global variables are recognized
-- FIX: Get greyed out unused code (semantic tokens)
-- FIX: Better completion: For example: Coc lua has type(v) == "completion"

-- local has_status, lsp_status = pcall(require, "lsp-status")
-- if has_status then
--     lsp_status.register_progress()
-- end
vim.diagnostic.config(
    {
        virtual_text = {
            prefix = "👈",
            severity = {min = vim.diagnostic.severity.W},
            source = "if_many"
        },
        signs = true,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
        float = {
            focusable = true,
            source = "if_many",
            border = style.current.border,
            header = {"", "DiagnosticHeader"}
        }
    }
)

local diagnostic_types = {
    {"Error", icon = icons.error},
    {"Warn", icon = icons.warn},
    {"Info", icon = icons.info},
    {"Hint", icon = icons.hint}
}

fn.sign_define(
    vim.tbl_map(
        function(t)
            local hl = "DiagnosticSign" .. t[1]
            return {
                name = hl,
                text = t.icon,
                texthl = hl,
                numhl = ("%sNr"):format(hl),
                linehl = ("%sLine"):format(hl)
            }
        end,
        diagnostic_types
    )
)

require("diaglist").init(
    {
        -- increase for noisy servers
        debounce_ms = 150
    }
)

require("lspsaga").setup(
    {
        error_sign = icons.error,
        warn_sign = icons.warn,
        hint_sign = icons.hint,
        infor_sign = icons.info,
        diagnostic_header_icon = "   ",
        code_action_icon = " ",
        finder_definition_icon = "  ",
        finder_reference_icon = "  ",
        max_preview_lines = 10,
        code_action_prompt = {
            enable = false,
            sign = true,
            sign_priority = 40,
            virtual_text = true
        },
        finder_action_keys = {
            open = "o",
            vsplit = "<C-v>",
            split = "<C-x>",
            quit = {"<C-[>", "<C-c>", "<Esc>"},
            scroll_down = "<C-d>",
            scroll_up = "<C-u>"
        },
        code_action_keys = {quit = {"<C-[>", "<C-c>", "<Esc>"}, exec = "<CR>"},
        rename_action_keys = {quit = {"<C-[>", "<C-c>", "<Esc>"}, exec = "<CR>"},
        rename_prompt_prefix = "➤",
        rename_prompt_populate = true,
        rename_output_qflist = {
            enable = true,
            auto_open_qflist = true
        },
        definition_preview_icon = "  ",
        border_style = "round",
        server_filetype_map = {},
        diagnostic_prefix_format = "%d. ",
        diagnostic_message_format = "%m %c",
        highlight_prefix = false
    }
)

-- local runtime_path = vim.split(package.path, ";")
-- table.insert(runtime_path, "lua/?.lua")
-- table.insert(runtime_path, "lua/?/init.lua")

local servers = {
    -- gopls = {
    --     opts = {
    --         settings = {
    --             gopls = {
    --                 analyses = {
    --                     unusedparams = true
    --                 },
    --                 completeUnimported = true,
    --                 staticcheck = true,
    --                 buildFlags = {"-tags=integration,e2e"},
    --                 hoverKind = "FullDocumentation",
    --                 linkTarget = "pkg.go.dev",
    --                 linksInHover = true,
    --                 experimentalWorkspaceModule = true,
    --                 experimentalPostfixCompletions = true,
    --                 codelenses = {
    --                     generate = true,
    --                     gc_details = true,
    --                     test = true,
    --                     tidy = true
    --                 },
    --                 usePlaceholders = true,
    --                 completionDocumentation = true,
    --                 deepCompletion = true
    --             }
    --         }
    --     }
    -- },
    sumneko_lua = {
        opts = {},
        update = function(on_attach, opts)
            opts =
                require("lua-dev").setup(
                {
                    library = {
                        vimruntime = true,
                        types = true,
                        plugins = true
                    },
                    lspconfig = {
                        cmd = {
                            "lua-language-server",
                            "-E",
                            "/usr/lib/lua-language-server/main.lua",
                            '--logpath="' .. fn.stdpath("cache") .. '/lua-language-server/log"',
                            '--metapath="' .. fn.stdpath("cache") .. '/lua-language-server/meta"'
                        },
                        on_attach = on_attach,
                        capabilities = opts.capabilities,
                        settings = {
                            Lua = {
                                runtime = {
                                    version = "LuaJIT"
                                },
                                completion = {
                                    callSnippet = "Replace",
                                    postfix = "."
                                },
                                diagnostics = {
                                    globals = {
                                        "vim",
                                        "require",
                                        "ex",
                                        "nvim",
                                        "packer_plugins",
                                        "use",
                                        "use_rocks",
                                        "it",
                                        "describe",
                                        "before_each",
                                        "after_each"
                                    },
                                    disable = {
                                        "lowercase-global",
                                        "redundant-parameter",
                                        "missing-parameter"
                                    },
                                    libraryFiles = "Opened",
                                    neededFileStatus = {
                                        ["different-requires"] = "None"
                                    }
                                },
                                IntelliSense = {
                                    traceLocalSet = true,
                                    traceReturn = true,
                                    traceBeSetted = true,
                                    traceFieldInject = true
                                },
                                -- This doesn't seem to work
                                workspace = {
                                    maxPreload = 100000,
                                    preloadFileSize = 50000
                                },
                                telemetry = {
                                    enable = false
                                },
                                window = {
                                    progressBar = true,
                                    statusBar = true
                                }
                            }
                        }
                    }
                }
            )
            opts.on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
                on_attach(client, bufnr)
            end
            return opts
        end
    },
    -- jsonls = {
    --     opts = {
    --         settings = {
    --             json = {
    --                 schemas = require("schemastore").json.schemas()
    --             }
    --         }
    --     },
    --     update = function(on_attach, opts)
    --         opts.on_attach = function(client, bufnr)
    --             client.server_capabilities.documentFormattingProvider = false
    --             client.server_capabilities.documentRangeFormattingProvider = false
    --             on_attach(client, bufnr)
    --         end
    --         return opts
    --     end
    -- },
    -- yamlls = {
    --     opts = {
    --         settings = {
    --             yaml = {
    --                 format = {enable = true, singleQuote = true},
    --                 validate = true,
    --                 hover = true,
    --                 completion = true,
    --                 schemaStore = {
    --                     enable = true,
    --                     url = "https://www.schemastore.org/api/json/catalog.json"
    --                 },
    --                 schemas = require("schemastore").json.schemas()
    --             }
    --         }
    --     }
    -- },
    -- sqls = {
    --     opts = {},
    --     update = function(on_attach, opts)
    --         -- neovim's LSP client does not currently support dynamic capabilities registration.
    --         -- sqls has a bad formatting.
    --         opts.on_attach = function(client, bufnr)
    --             client.server_capabilities.documentFormattingProvider = false
    --             client.server_capabilities.executeCommandProvider = true
    --             client.commands = require("sqls").commands
    --             require("sqls").setup({picker = "fzf"})
    --             on_attach(client, bufnr)
    --         end
    --         return opts
    --     end
    -- },
    -- html = {
    --     update = function(on_attach, opts)
    --         opts.on_attach = function(client, bufnr)
    --             client.server_capabilities.documentFormattingProvider = false
    --             client.server_capabilities.documentRangeFormattingProvider = false
    --             on_attach(client, bufnr)
    --         end
    --         return opts
    --     end
    -- },
    bashls = {}
    -- dockerls = {}
    -- pyright = {},
    -- tsserver = {},
    -- vimls = {}
    -- clangd = {
    --     update = function(on_attach, opts)
    --         opts.on_attach = function(client, bufnr)
    --             if vim.fn.findfile("uncrustify.cfg", ".;") ~= "" then
    --                 client.server_capabilities.documentFormattingProvider = false
    --                 client.server_capabilities.documentRangeFormattingProvider = false
    --             end
    --             on_attach(client, bufnr)
    --         end
    --         return opts
    --     end
    -- }
}

handlers.setup()
local lsp_setup = require("plugs.lsp.setup")

---@alias lsp_client 'vim.lsp.client'

---The function to pass to the LSP's on_attach callback.
---@param client lsp_client
---@param bufnr number
local function on_attach(client, bufnr)
    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

    require("lsp_signature").on_attach(
        {
            use_lspsaga = true,
            fix_pos = true,
            floating_window = false, --hides floating window during completion (use hint instead)
            floating_window_above_cur_line = true,
            bind = true,
            hint_enable = true,
            hi_parameter = "Search",
            zindex = 50,
            handler_opts = {
                border = style.current.border
            }
        }
    )
    require("aerial").on_attach(client, bufnr)
    -- require("illuminate").on_attach(client)

    -- if has_status then
    --     lsp_status.on_attach(client)
    -- end

    if client.name == "typescript" or client.name == "tsserver" then
        require("plugs.lsp.typescript").setup(client)
    end

    if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].readonly then
        vim.diagnostic.disable(bufnr)
    end

    -- TODO: turn these into: client.supports_method("textDocument/codeAction")
    vim.api.nvim_buf_call(
        bufnr,
        function()
            -- Function to run for imports
            local imports_hook = function()
            end
            -- Function to run after formatting
            local format_hook = function()
            end

            local caps = client.server_capabilities

            -- if caps.documentFormattingProvider then
            --     lsp_setup.document_formatting()
            --     format_hook = function()
            --         vim.lsp.buf.format({async = false})
            --     end
            -- end

            if caps.workspace and caps.workspace.workspaceFolders.supported then
                lsp_setup.workspace_folder_properties()
            end

            local mappings = {
                {
                    capability = "codeActionProvider",
                    func = function()
                        lsp_setup.code_action()

                        -- Either is it set to true, or there is a specified set of
                        -- capabilities. Sumneko doesn't support it, but the
                        -- client.supports_method returns true.

                        -- local can_organise_imports =
                        --     type(caps.codeActionProvider) == "table" and
                        --     _t(caps.codeActionProvider.codeActionKinds):contains("source.organizeImports")
                        -- if can_organise_imports then
                        --     lsp_setup.setup_organise_imports()
                        --     imports_hook = lsp_setup.lsp_organise_imports
                        -- end
                    end
                },
                {capability = "documentSymbolProvider", func = lsp_setup.document_symbol},
                {capability = "workspaceSymbolProvider", func = lsp_setup.workspace_symbol},
                {capability = "hoverProvider", func = lsp_setup.hover},
                {capability = "renameProvider", func = lsp_setup.rename},
                {capability = "codeLensProvider", func = lsp_setup.code_lens},
                {capability = "definitionProvider", func = lsp_setup.goto_definition},
                {capability = "referencesProvider", func = lsp_setup.find_references},
                {capability = "declarationProvider", func = lsp_setup.declaration},
                {capability = "implementationProvider", func = lsp_setup.implementation},
                {capability = "typeDefinitionProvider", func = lsp_setup.type_definition},
                {capability = "signatureHelpProvider", func = lsp_setup.signature_help},
                {capability = "callHierarchyProvider", func = lsp_setup.call_hierarchy}
                -- {capability = "documentRangeFormattingProvider", func = lsp_setup.document_range_formatting},
            }

            for mapping, val in pairs(mappings) do
                if not val.capability or client.server_capabilities[val.capability] then
                    if type(val.func) == "string" then
                        lsp_setup[val.func]()
                    elseif type(val.func) == "function" then
                        val.func()
                    end
                end
            end

            lsp_setup.setup_diagnostics()
            lsp_setup.support_commands()
            lsp_setup.setup_events(client, bufnr, {imports_hook, format_hook})
            lsp_setup.other_mappings()
        end
    )
end

local attach_wrap = function(client, ...)
    on_attach(client, ...)
end

-- Enable (broadcasting) snippet capability for completion.
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- if has_status then
--     capabilities = vim.tbl_deep_extend("force", capabilities, lsp_status.capabilities)
-- end
capabilities.textDocument.completion.completionItem.snippetSupport = true

local null_ls = require("null-ls")
null_ls.setup(
    {
        sources = {
            null_ls.builtins.formatting.fixjson
            -- null_ls.builtins.formatting.prettier.with(
            --     {
            --         disabled_filetypes = {"html"}
            --     }
            -- ),
            -- null_ls.builtins.formatting.stylua.with(
            --     {
            --         extra_args = {"--indent-type=Spaces", "--indent-width=2", "--column-width=100"}
            --     }
            -- ),
            -- null_ls.builtins.diagnostics.selene,
            -- null_ls.builtins.diagnostics.golangci_lint,
            -- null_ls.builtins.diagnostics.buf,
            -- null_ls.builtins.formatting.uncrustify.with(
            --     {
            --         extra_args = function()
            --             return {
            --                 "-c",
            --                 vim.fn.findfile("uncrustify.cfg", ".;"),
            --                 "--no-backup"
            --             }
            --         end
            --     }
            -- )
        },
        on_attach = attach_wrap
    }
)

for name, server in pairs(servers) do
    local opts =
        vim.tbl_deep_extend(
        "force",
        {
            on_attach = attach_wrap,
            capabilities = capabilities
        },
        server.opts or {}
    )

    if server.update then
        opts = server.update(attach_wrap, opts)
    end
    lspconfig[name].setup(opts)
end

return M
