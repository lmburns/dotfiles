local M = {}

local ex = nvim.ex
local fn = vim.fn
local cmd = vim.cmd

local dev = require("dev")
local log = require("common.log")
local utils = require("common.utils")
local bcommand = utils.bcommand
local augroup = utils.augroup

local diagnotic_icons = require("style").icons.lsp

local fzf = require("fzf-lua")
local fzflsp = require("fzf-lua.providers.lsp")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

---Get the diagnostic icon and highlight group based on severity
---@param severity number
---@return string, string
M.diagnostic_icon_by_severity = function(severity)
    local icon, highlight
    if severity == 1 then
        icon = diagnotic_icons.error
        highlight = "DiagnosticError"
    elseif severity == 2 then
        icon = diagnotic_icons.warn
        highlight = "DiagnosticWarn"
    elseif severity == 3 then
        icon = diagnotic_icons.info
        highlight = "DiagnosticInfo"
    elseif severity == 4 then
        icon = diagnotic_icons.hint
        highlight = "DiagnosticHint"
    end
    return icon, highlight
end

---Wrapper to create an easier mapping
local function map(mode, lhs, rhs, desc, ...)
    utils.map(mode, lhs, rhs, {buffer = true, desc = desc, ...})
end

-- function M.lsp_organize_imports()
--   local context = { source = { organizeImports = true } }
--   vim.validate({ context = { context, "table", true } })
--
--   local params = vim.lsp.util.make_range_params()
--   params.context = context
--
--   local method = "textDocument/codeAction"
--   local timeout = 1000 -- ms
--
--   local ok, resp = pcall(vim.lsp.buf_request_sync, 0, method, params, timeout)
--   if not ok or not resp then
--     return
--   end
--
--   for _, client in ipairs(vim.lsp.get_active_clients()) do
--     local offset_encoding = client.offset_encoding or "utf-16"
--     if client.id and resp[client.id] then
--       local result = resp[client.id].result
--       if result and result[1] and result[1].edit then
--         local edit = result[1].edit
--         if edit then
--           vim.lsp.util.apply_workspace_edit(result[1].edit, offset_encoding)
--         end
--       end
--     end
--   end
-- end
--
---Returns the name of the struct, method or function.
---@return string
function M.get_current_node_name()
    local ts_utils = require("nvim-treesitter.ts_utils")
    local cur_node = ts_utils.get_node_at_cursor()
    local type_patterns = {
        method_declaration = 2,
        function_declaration = 1,
        type_spec = 0
    }
    local stop = false
    local index = 1
    while cur_node do
        for rgx, k in pairs(type_patterns) do
            if cur_node:type() == rgx then
                stop = true
                index = k
                break
            end
        end
        if stop then
            break
        end
        cur_node = cur_node:parent()
    end

    if not cur_node then
        vim.notify(
            "Test not found",
            vim.lsp.log_levels.WARN,
            {
                title = "User Command",
                timeout = 1000
            }
        )
        return ""
    end
    return (vim.treesitter.query.get_node_text(cur_node:child(index)))[1]
end

---Formats a range if given.
---@param range_given boolean
---@param line1 number
---@param line2 number
---@param bang boolean
local function format_command(range_given, line1, line2, bang)
    if range_given then
        vim.lsp.buf.range_formatting(nil, {line1, 0}, {line2, 99999999})
    elseif bang then
        vim.lsp.buf.format({async = false})
    else
        vim.lsp.buf.format({async = true})
    end
end

---Runs code actions on a given range.
---@param range_given boolean
---@param line1 number
---@param line2 number
local function code_action(range_given, line1, line2)
    if range_given then
        vim.lsp.buf.range_code_action(nil, {line1, 0}, {line2, 99999999})
    else
        fzf.lsp_code_actions()
    end
end

function M.code_action()
    bcommand(
        "CodeAction",
        function(tbl)
            code_action(tbl.range ~= 0, tbl.line1, tbl.line2)
        end,
        {range = true}
    )

    map("v", "<Leader>ca", ":'<,'>CodeAction<CR>", "Code action")
    map("n", "<A-CR>", "<cmd>lua require('code_action_menu').open_code_action_menu()<CR>")
    map("n", "<C-A-CR>", fzf.lsp_code_actions, "Code action")

    -- map("n", "<A-CR>", "<cmd>lua require('code_action_menu').open_code_action_menu('cursor')<CR>")
    -- map("n", "<C-A-CR>", "<cmd>lua require('code_action_menu').open_code_action_menu('line')<CR>")
    -- map("x", "<A-CR>", [[:<C-u>lua require('plugs.coc').code_action(vim.fn.visualmode())<CR>]])
end
--
-- function M.setup_organise_imports()
--   nnoremap("<leader>i", M.lsp_organise_imports, "Organise imports")
-- end
--
-- function M.document_formatting()
--   nnoremap("<leader>gq", vim.lsp.buf.format, "Format buffer")
-- end
--
-- local function document_range_formatting(args)
--   format_command(args.range ~= 0, args.line1, args.line2, args.bang)
-- end
--
-- -- selene: allow(global_usage)
-- local function format_range_operator()
--   local old_func = vim.go.operatorfunc
--   _G.op_func_formatting = function()
--     local start = vim.api.nvim_buf_get_mark(0, "[")
--     local finish = vim.api.nvim_buf_get_mark(0, "]")
--     vim.lsp.buf.range_formatting({}, start, finish)
--     vim.go.operatorfunc = old_func
--     _G.op_func_formatting = nil
--   end
--   vim.go.operatorfunc = "v:lua.op_func_formatting"
--   vim.api.nvim_feedkeys("g@", "n", false)
-- end
--
-- function M.document_range_formatting()
--   quick.buffer_command("Format", document_range_formatting, { range = true })
--   -- vnoremap("gq", document_range_formatting, "Format range")
--   nnoremap("gq", format_range_operator, "Format range")
--   -- vim.api.nvim_set_keymap("n", "gm", "<cmd>lua format_range_operator()<CR>", { noremap = true })
--
--   vim.bo.formatexpr = "v:lua.vim.lsp.formatexpr()"
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Rename                          │
-- ╰──────────────────────────────────────────────────────────╯
local function rename_symbol(args)
    if args.args == "" then
        vim.lsp.buf.rename()
    else
        vim.lsp.buf.rename(args.args)
    end
end

function M.rename()
    map("n", "<Leader>rn", rename_symbol, "Rename symbol")
    bcommand("Rename", rename_symbol, {nargs = "?"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Hover                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.hover()
    map(
        "n",
        "K",
        function()
            local ft = vim.bo.ft
            if _t({"help", "vim"}):contains(ft) then
                cmd(("sil! h %s"):format(fn.expand("<cword>")))
            elseif ft == "man" then
                ex.Man(("%s"):format(fn.expand("<cword>")))
            elseif fn.expand("%:t") == "Cargo.toml" then
                require("crates").show_popup()
            else
                -- cmd(("!%s %s"):format(o.keywordprg, fn.expand("<cword>")))
                -- require("lspsaga.hover").render_hover_doc()
                vim.lsp.buf.hover()
            end
        end,
        {buffer = true, silent = true, desc = "Show hover"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      SignatureHelp                       │
-- ╰──────────────────────────────────────────────────────────╯
function M.signature_help()
    -- map("n", "<Leader>kk", vim.lsp.buf.signature_help, "Show signature help")
    map("i", "<M-o>", vim.lsp.buf.signature_help, "Show signature help")

    augroup(
        "LspSignatureHelp",
        {
            -- This one might get annoying
            event = "CursorHoldI",
            pattern = "*",
            command = function()
                vim.lsp.buf.signature_help()
            end,
            desc = "Show signature help when completing function"
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Definition                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.goto_definition()
    map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", "Goto definition")
    map(
        "n",
        "<Leader>kd",
        function()
            builtin.lsp_definitions(themes.get_cursor({}))
        end,
        "Goto definition (telescope)"
    )
    map(
        "n",
        "<C-x><C-d>",
        function()
            fzf.lsp_definitions({jump_to_single_result = true})
        end,
        "Goto definition (fzf)"
    )

    -- vim.bo.tagfunc = "v:lua.vim.lsp.tagfunc"
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Declaration                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.declaration()
    map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", "Goto declaration")
    map(
        "n",
        "<C-x><C-S-d>",
        function()
            fzf.lsp_declarations({jump_to_single_result = true})
        end,
        "Goto declaration (fzf)"
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Type Definition                      │
-- ╰──────────────────────────────────────────────────────────╯
function M.type_definition()
    map("n", "gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Goto type definition")
    map(
        "n",
        "<Leader>ky",
        function()
            builtin.lsp_type_definitions(themes.get_dropdown({}))
        end,
        "Goto type definition (telescope)"
    )
    map(
        "n",
        "<C-x><C-S-d>",
        function()
            fzf.lsp_typedefs({jump_to_single_result = true})
        end,
        "Goto type definition (fzf)"
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Implementation                      │
-- ╰──────────────────────────────────────────────────────────╯
function M.implementation()
    map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", "Goto implementation")
    map(
        "n",
        "<Leader>ki",
        function()
            builtin.lsp_implementations(themes.get_dropdown({}))
        end,
        "Goto implementation (telescope)"
    )
    map(
        "n",
        "<C-x><C-i>",
        function()
            fzf.lsp_implementations({jump_to_single_result = true})
        end,
        "Goto implementation (fzf)"
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        References                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.find_references()
    map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", "Goto references")
    map(
        "n",
        "<Leader>kr",
        function()
            builtin.lsp_references(themes.get_dropdown({}))
        end,
        "Goto references (telescope)"
    )
    map(
        "n",
        "<C-x><C-r>",
        function()
            fzf.lsp_references({jump_to_single_result = true})
        end,
        "Goto references (fzf)"
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Symbols                          │
-- ╰──────────────────────────────────────────────────────────╯

---Functions dealing with the LSP's current document symbols
function M.document_symbol()
    -- vim.lsp.buf.document_symbol()
    -- FIX: Still shows filename
    local perform = function()
        fzf.lsp_document_symbols(
            {
                ignore_filename = true,
                jump_to_single_result = true,
                fzf_cli_args = "--nth 2.."
            }
        )
    end

    map(
        "n",
        ";s",
        function()
            builtin.lsp_document_symbols()
        end,
        "Document symbols"
    )

    bcommand("DocumentSymbols", perform)
end

---Functions dealing with the LSP's current workspace symbols
function M.workspace_symbol()
    -- vim.lsp.buf.workspace_symbol()
    map(
        "n",
        ";S",
        function()
            builtin.lsp_workspace_symbols()
        end,
        "Workspace symbols"
    )
    bcommand("WorkspaceSymbols", fzf.lsp_live_workspace_symbols)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Callers/Callees                      │
-- ╰──────────────────────────────────────────────────────────╯
function M.call_hierarchy()
    bcommand("Callers", fzf.lsp_incoming_calls)
    bcommand("Callees", fzf.lsp_outgoing_calls)
    map("n", "<Leader>kc", fzf.lsp_incoming_calls, "Show incoming calls")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Workspace Folder                     │
-- ╰──────────────────────────────────────────────────────────╯
function M.workspace_folder_properties()
    local function add_workspace(args)
        vim.lsp.buf.add_workspace_folder(args.args and fn.fnamemodify(args.args, ":p"))
    end

    bcommand("AddWorkspace", add_workspace, {range = true, nargs = "?", complete = "dir"})
    bcommand(
        "RemoveWorkspace",
        function(args)
            vim.lsp.buf.remove_workspace_folder(args.args)
        end,
        {range = true, nargs = "?", complete = "customlist,v:lua.vim.lsp.buf.list_workspace_folders"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         CodeLens                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.code_lens()
    map("n", "<Leader>cr", vim.lsp.codelens.run, "Run codelens")

    augroup(
        "LspCodeLens",
        {
            event = {"CursorHold", "CursorHoldI", "InsertLeave"},
            command = vim.lsp.codelens.refresh,
            buffer = 0
        }
    )
end
--
-- function M.setup_completions()
--   inoremap("<C-j>", "<C-n>", "next completion items")
--   inoremap("<C-k>", "<C-p>", "previous completion items")
-- end
--
-- local lsp_events_group = vim.api.nvim_create_augroup("LSP_EVENTS", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
--   group = lsp_events_group,
--   pattern = "go.mod",
--   callback = function()
--     vim.opt_local.filetype = "gomod"
--   end,
-- })

---Setup events for the LSP
---@param imports function
---@param format function
function M.setup_events(imports, format)
    augroup(
        "LspPopupDiagnostics",
        {
            event = "CursorHold",
            buffer = 0,
            command = function()
                vim.diagnostic.open_float(0, {scope = "cursor", border = "rounded"})
            end,
            desc = "Make diagnostics popup under cursor"
        }
    )

    augroup(
        "LspSetupEvents",
        {
            event = "BufWritePre",
            buffer = 0,
            command = function()
                imports()
                format()
            end,
            desc = "Format and imports"
        },
        {
            event = {"BufReadPost", "BufNewFile"},
            pattern = {"*/templates/*.yaml", "*/templates/*.tpl"},
            command = "silent LspStop"
        },
        {
            event = "InsertEnter",
            pattern = "go.mod",
            command = function()
                vim.opt_local.formatoptions:remove({"t"})
            end,
            once = true,
            desc = "Don't wrap go.mod lines"
        }
        -- {
        --     event = "BufWritePre",
        --     pattern = "go.mod",
        --     command = function(args)
        --         local filename = vim.fn.expand("%:p")
        --         lsp.go_mod_tidy(tonumber(args.buf), filename)
        --     end,
        --     desc = "run go mod tidy on save"
        -- }
    )

    -- local function go_mod_check(args)
    --     lsp.go_mod_check_upgrades(args.match)
    -- end
    --
    -- vim.api.nvim_create_autocmd(
    --     "BufRead",
    --     {
    --         group = lsp_events_group,
    --         pattern = "go.mod",
    --         callback = go_mod_check,
    --         desc = "check for updates"
    --     }
    -- )
end
--
-- function M.fix_null_ls_errors()
--   local default_exe_handler = vim.lsp.handlers["workspace/executeCommand"]
--   vim.lsp.handlers["workspace/executeCommand"] = function(err, ...)
--     -- supress NULL_LS error msg
--     local prefix = "NULL_LS"
--     if err and err.message:sub(1, #prefix) == prefix then
--       return
--     end
--     return default_exe_handler(err, ...)
--   end
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Support Commands                     │
-- ╰──────────────────────────────────────────────────────────╯

function M.support_commands()
    bcommand(
        "ListWorkspace",
        function()
            utils.cool_echo("Workspace Folders: " .. dev.inspect(vim.lsp.buf.list_workspace_folders()), "Special")
        end
    )
    bcommand("Log", "execute '<mods> pedit +$' v:lua.vim.lsp.get_log_path()")
    bcommand(
        "Test",
        function()
            local name = M.get_current_node_name()
            if name == "" then
                return nil
            end

            local pattern = "test" .. name
            vim.lsp.buf.workspace_symbol(pattern)
        end
    )

    local function restart_lsp()
        nvim.ex.LspStop()
        vim.defer_fn(nvim.ex.LspStart, 1000)
    end
    bcommand("RestartLsp", restart_lsp, {nargs = 0})
    map("n", "<Leader>re", restart_lsp, "Reload LSP server")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Diagnostics                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.setup_diagnostics()
    -- map("n", "<Leader>dd", vim.diagnostic.open_float, "Show diagnostics")

    map(
        "n",
        "[g",
        function()
            vim.diagnostic.goto_prev({float = false})
        end,
        "Previous diagnostic"
    )
    map(
        "n",
        "]g",
        function()
            vim.diagnostic.goto_next({float = false})
        end,
        "Next diagnostic"
    )

    map(
        "n",
        "[G",
        function()
            vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})
        end,
        "Previous error"
    )
    map(
        "n",
        "]G",
        function()
            vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})
        end,
        "Next error"
    )

    map("n", "<Leader>j,", vim.diagnostic.setloclist, "Diagnostics (document)")
    map("n", "<Leader>j;", vim.diagnostic.setqflist, "Diagnostics (workspace)")

    map(
        "n",
        "<C-x><C-h>",
        function()
            builtin.diagnostics()
        end,
        "Telescope workspace diagnostics"
    )
    map(
        "n",
        "<C-x>h",
        function()
            builtin.diagnostics({bufnr = 0})
        end,
        "Telescope document diagnostics"
    )

    bcommand(
        "Diagnostics",
        function()
            fzflsp.diagnostics({})
        end
    )
    bcommand(
        "DiagnosticsAll",
        function()
            fzflsp.workspace_diagnostics({})
        end
    )
end

return M
