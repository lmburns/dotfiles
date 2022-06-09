local M = {}

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Setting Handlers                     │
-- ╰──────────────────────────────────────────────────────────╯

local ex = nvim.ex
local api = vim.api

local ns = api.nvim_create_namespace("severe-diagnostics")

---Credit: akinsho
---Restricts nvim's diagnostic signs to only the single most severe one per line
---@see `:help vim.diagnostic`
local function max_diagnostic(callback)
    return function(_, bufnr, _, opts)
        -- Get all diagnostics from the whole buffer rather than just the
        -- diagnostics passed to the handler
        local diagnostics = vim.diagnostic.get(bufnr)
        -- Find the "worst" diagnostic per line
        local max_severity_per_line = {}
        for _, d in pairs(diagnostics) do
            local m = max_severity_per_line[d.lnum]
            if not m or d.severity < m.severity then
                max_severity_per_line[d.lnum] = d
            end
        end
        -- Pass the filtered diagnostics (with our custom namespace) to
        -- the original handler
        callback(ns, bufnr, vim.tbl_values(max_severity_per_line), opts)
    end
end

---Wrapper for telescope
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

---Alternative wrapper for telescope
local function wrap_options(custom, handler)
    return function(opts)
        opts = opts and vim.tbl_extend(opts, custom) or custom
        if type(handler) == "string" then
            require("telescope.builtin")[handler](opts)
        else
            handler(opts)
        end
    end
end

---Customize the LSP's handlers
function M.setup()
    -- vim.lsp.handlers["textDocument/declaration"] = location_handler
    -- vim.lsp.handlers["textDocument/definition"] = location_handler
    -- vim.lsp.handlers["textDocument/typeDefinition"] = location_handler
    -- vim.lsp.handlers["textDocument/implementation"] = location_handler

    vim.lsp.handlers["textDocument/codeLens"] = vim.lsp.codelens.on_codelens
    vim.lsp.handlers["textDocument/documentSymbol"] = require("telescope.builtin").lsp_document_symbols
    vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
        local client_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
        if err then
            vim.notify(err.message)
            return
        end
        if result == nil then
            vim.notify("Location not found")
            return
        end
        if vim.tbl_islist(result) and result[1] then
            vim.lsp.util.jump_to_location(result[1], client_encoding)

            if #result > 1 then
                fn.setqflist(vim.lsp.util.locations_to_items(result, client_encoding))
                ex.copen()
            end
        else
            vim.lsp.util.jump_to_location(result, client_encoding)
        end
    end

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "rounded"})
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = "rounded"})

    -- FIX: This causes an error when grepping into a directory from another directory
    -- vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
    --     local client = vim.lsp.get_client_by_id(ctx.client_id)
    --     local lvl = ({"ERROR", "WARN", "INFO", "DEBUG"})[result.type]
    --     vim.notify(
    --         result.message,
    --         lvl,
    --         {
    --             title = "LSP | " .. client.name,
    --             timeout = 10000,
    --             keep = function()
    --                 return lvl == "ERROR" or lvl == "WARN"
    --             end
    --         }
    --     )
    -- end

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

    -- ╭───────╮
    -- │ Signs │
    -- ╰───────╯
    local signs_handler = vim.diagnostic.handlers.signs
    vim.diagnostic.handlers.signs = {
        show = max_diagnostic(signs_handler.show),
        hide = function(_, bufnr)
            signs_handler.hide(ns, bufnr)
        end
    }

    local virt_text_handler = vim.diagnostic.handlers.virtual_text
    vim.diagnostic.handlers.virtual_text = {
        show = max_diagnostic(virt_text_handler.show),
        hide = function(_, bufnr)
            virt_text_handler.hide(ns, bufnr)
        end
    }
end

return M
