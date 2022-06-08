-- vim.lsp.set_log_level("debug")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local lspconfig = require("lspconfig")
local saga = require("lspsaga")
local lsp_installer = require("nvim-lsp-installer")

local utils = require("common.utils")
local augroup = utils.augroup

local fn = vim.fn

vim.diagnostic.config(
    {
        virtual_text = {
            -- prefix = "👈",
            severity = {min = vim.diagnostic.severity.W},
            source = "if_many"
        },
        signs = true,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
        float = {
            focusable = true,
            source = "always",
            border = require("style").current.border,
            header = {" Diagnostics:", "DiagnosticHeader"}
        }
    }
)

local signs = {Error = " ", Warn = " ", Hint = " ", Info = " "}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    local nr = "DiagnosticLineNr" .. type
    fn.sign_define(hl, {text = icon, texthl = hl, linehl = "", numhl = nr})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Setting Handlers                     │
-- ╰──────────────────────────────────────────────────────────╯
local function location_handler(_, result, ctx, _)
    if result == nil or vim.tbl_isempty(result) then
        return nil
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)

    -- textDocument/definition can return Location or Location[]
    -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition

    local has_telescope = pcall(require, "telescope")
    if vim.tbl_islist(result) then
        if #result == 1 then
            vim.lsp.util.jump_to_location(result[1], client.offset_encoding)
        elseif has_telescope then
            local opts = {}
            local pickers = require("telescope.pickers")
            local finders = require("telescope.finders")
            local make_entry = require("telescope.make_entry")
            local conf = require("telescope.config").values
            local items = vim.lsp.util.locations_to_items(result, client.offset_encoding)
            pickers.new(
                opts,
                {
                    prompt_title = "LSP Locations",
                    finder = finders.new_table(
                        {
                            results = items,
                            entry_maker = make_entry.gen_from_quickfix(opts)
                        }
                    ),
                    previewer = conf.qflist_previewer(opts),
                    sorter = conf.generic_sorter(opts)
                }
            ):find()
        else
            vim.fn.setqflist(
                {},
                " ",
                {
                    title = "LSP locations",
                    items = vim.lsp.util.locations_to_items(result, client.offset_encoding)
                }
            )
            vim.cmd([[botright copen]])
        end
    else
        vim.lsp.util.jump_to_location(result, client.offset_encoding)
    end
end

vim.lsp.handlers["textDocument/declaration"] = location_handler
vim.lsp.handlers["textDocument/definition"] = location_handler
vim.lsp.handlers["textDocument/typeDefinition"] = location_handler
vim.lsp.handlers["textDocument/implementation"] = location_handler

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "rounded"})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = "rounded"})

local diagnostics_handler =
    vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        underline = false,
        virtual_text = false,
        signs = true,
        update_in_insert = false
    }
)
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, context, config)
    local client = vim.lsp.get_client_by_id(context.client_id)
    if client.config.diagnostics ~= false then
        diagnostics_handler(err, result, context, config)
    end
end

-- Make diagnostic popup like Coc does
augroup(
    "LspPopupDiagnostics",
    {
        event = "CursorHold",
        pattern = "*",
        command = function()
            vim.diagnostic.open_float(0, {scope = "cursor", border = "rounded"})
        end
    },
    {
        event = "CursorHoldI",
        pattern = "*",
        command = function()
            vim.lsp.buf.signature_help()
        end
    }
)

saga.init_lsp_saga(
    {
        error_sign = "",
        warn_sign = "",
        hint_sign = "",
        infor_sign = "",
        diagnostic_header_icon = "   ",
        code_action_icon = " ",
        finder_definition_icon = "  ",
        finder_reference_icon = "  ",
        max_preview_lines = 10,
        code_action_prompt = {
            enable = false,
            sign = false,
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
        definition_preview_icon = "  ",
        border_style = "rounded",
        rename_prompt_prefix = "➤",
        server_filetype_map = {},
        diagnostic_prefix_format = "%d. "
    }
)

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

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
                                    neededFileStatus = {
                                        ["different-requires"] = "None"
                                    }
                                },
                                workspace = {
                                    maxPreload = 10000,
                                    preloadFileSize = 10000
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

local lsp_util = require("plugs.lsp.util")

---@alias lsp_client 'vim.lsp.client'

---The function to pass to the LSP's on_attach callback.
---@param client lsp_client
---@param bufnr number
-- stylua: ignore start
local function on_attach(client, bufnr) --{{{
    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
    -- vim.bo.tagfunc = "v:lua.vim.lsp.tagfunc"

    require("lsp_signature").on_attach(
        {
            bind = true,
            use_lspsaga = false,
            floating_window = true,
            fix_pos = true,
            hint_enable = true,
            hi_parameter = "Search",
            handler_opts = {"double"}
        }
    )
    require("aerial").on_attach(client)
    require("illuminate").on_attach(client)

    -- TODO: find out how to disable the statuline badges as well.
    if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
        vim.diagnostic.disable(bufnr)
    end

    -- TODO: turn these into: client.supports_method("textDocument/codeAction")
    vim.api.nvim_buf_call(
        bufnr,
        function()
            --{{{
            -- Contains functions to be run before writing the buffer. The format
            -- function will format the while buffer, and the imports function will
            -- organise imports.
            local imports_hook = function()
            end
            local format_hook = function()
            end
            local caps = client.server_capabilities

            -- if caps.codeActionProvider then
            --     lsp_util.code_action()
            --
            --     -- Either is it set to true, or there is a specified set of
            --     -- capabilities. Sumneko doesn't support it, but the
            --     -- client.supports_method returns true.
            --     local can_organise_imports =
            --         type(caps.codeActionProvider) == "table" and
            --         _t(caps.codeActionProvider.codeActionKinds):contains("source.organizeImports")
            --     if can_organise_imports then
            --         lsp_util.setup_organise_imports()
            --         imports_hook = lsp_util.lsp_organise_imports
            --     end
            -- end
            --
            -- if caps.documentFormattingProvider then
            --     lsp_util.document_formatting()
            --     format_hook = function()
            --         vim.lsp.buf.format({async = false})
            --     end
            -- end
            --
            -- local workspace_folder_supported = caps.workspace and caps.workspace.workspaceFolders.supported
            -- if workspace_folder_supported then
            --     lsp_util.workspace_folder_properties()
            -- end
            -- if caps.workspaceSymbolProvider then
            --     lsp_util.workspace_symbol()
            -- end

            if caps.hoverProvider then
                lsp_util.hover()
            end

            -- if caps.renameProvider then
            --     lsp_util.rename()
            -- end
            -- if caps.codeLensProvider then
            --     lsp_util.code_lens()
            -- end

            -- if caps.definitionProvider then
            --     lsp_util.goto_definition()
            -- end

            -- if caps.referencesProvider then
            --     lsp_util.find_references()
            -- end
            -- if caps.declarationProvider then
            --     lsp_util.declaration()
            -- end
            -- if caps.signatureHelpProvider then
            --     lsp_util.signature_help()
            -- end
            -- if caps.implementationProvider then
            --     lsp_util.implementation()
            -- end
            -- if caps.typeDefinitionProvider then
            --     lsp_util.type_definition()
            -- end
            -- if caps.documentSymbolProvider then
            --     lsp_util.document_symbol()
            -- end
            -- if caps.documentRangeFormattingProvider then
            --     lsp_util.document_range_formatting()
            -- end
            -- if caps.callHierarchyProvider then
            --     lsp_util.call_hierarchy()
            -- end
            --
            -- lsp_util.setup_diagnostics()
            -- lsp_util.setup_completions()
            -- lsp_util.support_commands()
            -- lsp_util.setup_events(imports_hook, format_hook)
            -- lsp_util.fix_null_ls_errors()
        end
    )
end

local attach_wrap = function(client, ...)
    on_attach(client, ...)
end
--
-- -- Enable (broadcasting) snippet capability for completion.
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

local null_ls = require("null-ls") -- NULL LS Setup {{{
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
) --}}}

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
