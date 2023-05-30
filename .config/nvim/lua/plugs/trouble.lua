---@module 'plugs.trouble'
local M = {}

local lazy = require("usr.lazy")
local shared = require("usr.shared")
local F = shared.F
local trouble = F.npcall(lazy.require_on.call_rec, "trouble")
if not trouble then
    return
end

local icon = require("usr.style").icons
local coc = require("plugs.coc")
local log = require("usr.lib.log")
local mpi = require("usr.api")
local map = mpi.map

local cmd = vim.cmd

function M.setup()
    trouble.setup({
        debug = false,
        position = "bottom", -- position of the list can be: bottom, top, left, right
        height = 15,         -- height of the trouble list when position is top or bottom
        width = 50,          -- width of the list when position is left or right
        icons = true,        -- use devicons for filenames
        -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
        mode = "workspace_diagnostics",
        fold_open = "", -- icon used for open folds
        fold_closed = "", -- icon used for closed folds
        group = true,      -- group results by file
        padding = true,    -- add an extra new line on top of the list
        action_keys = {
            -- key mappings for actions in the trouble list
            -- map to {} to remove a mapping, for example:
            -- close = {},
            close = "q",                 -- close the list
            cancel = "<esc>",            -- cancel the preview and get back to your last window / buffer / cursor
            refresh = "r",               -- manually refresh
            jump = {"<cr>", "<tab>"},    -- jump to the diagnostic or open / close folds
            open_split = {"<c-x>"},      -- open buffer in new split
            open_vsplit = {"<c-v>"},     -- open buffer in new vsplit
            open_tab = {"<c-t>"},        -- open buffer in new tab
            jump_close = {"o"},          -- jump to the diagnostic and close the list
            toggle_mode = "m",           -- toggle between "workspace" and "document" diagnostics mode
            toggle_preview = "P",        -- toggle auto_preview
            hover = "K",                 -- opens a small popup with the full multiline message
            preview = "p",               -- preview the diagnostic location
            close_folds = {"zC", "zc"},  -- close all folds
            open_folds = {"zR", "zo"},   -- open all folds
            toggle_fold = {"zA", "za"},  -- toggle fold of current file
            previous = "k",              -- preview item
            next = "j",                  -- next item
        },
        indent_lines = true,             -- add an indent guide below the fold icons
        auto_open = false,               -- automatically open the list when you have diagnostics
        auto_close = false,              -- automatically close the list when you have no diagnostics
        auto_preview = true,             -- automatically preview the location of the diagnostic. <esc> to close preview
        auto_fold = false,               -- automatically fold a file trouble list at creation
        auto_jump = {"lsp_definitions"}, -- for the given modes, automatically jump if there is only a single result
        signs = {
            -- icons / text used for a diagnostic
            error = icon.lsp.error,
            warning = icon.lsp.warn,
            hint = icon.lsp.hint,
            information = icon.lsp.info,
            other = "﫠",
        },
        use_diagnostic_signs = true, -- enabling this will use the signs defined in your lsp client
        track_cursor = true,         -- automatically track the cursor and update the selected item
    })
end

function M.toggle_workspace()
    if #coc.workspace > 0 then
        cmd.TroubleToggle("coc_workspace_diagnostics")
    else
        log.warn("No workspace diagnostics", {title = "Trouble"})
    end
end

function M.toggle_document()
    if #coc.document > 0 then
        cmd.TroubleToggle("coc_document_diagnostics")
    else
        log.warn("No document diagnostics", {title = "Trouble"})
    end
end

local function init()
    M.setup()

    local opts = {skip_groups = true, jump = true}
    map("n", "]v", F.ithunk(trouble.next, opts), {desc = "Trouble next"})
    map("n", "[v", F.ithunk(trouble.previous, opts), {desc = "Trouble previous"})
    map("n", "]V", F.ithunk(trouble.last, opts), {desc = "Trouble last"})
    map("n", "[V", F.ithunk(trouble.first, opts), {desc = "Trouble first"})

    map("n", "<Leader>xx", "<cmd>TroubleToggle<cr>", {desc = "Trouble resume"})
    map(
        "n",
        "<Leader>xd",
        "TroubleToggle coc_definitions",
        {cmd = true, desc = "Trouble definitions"}
    )
    map(
        "n",
        "<Leader>xR",
        "TroubleToggle coc_references",
        {cmd = true, desc = "Trouble references"}
    )

    map(
        "n",
        "<Leader>xr",
        "TroubleToggle coc_references_used",
        {cmd = true, desc = "Trouble references used"}
    )

    map(
        "n",
        "<Leader>xy",
        "TroubleToggle coc_type_definitions",
        {cmd = true, desc = "Trouble type definition"}
    )

    map(
        "n",
        "<Leader>xi",
        "TroubleToggle coc_implementations",
        {cmd = true, desc = "Trouble implementations"}
    )

    map(
        "n",
        "<Leader>x;",
        "require('plugs.trouble').toggle_workspace()",
        {lcmd = true, desc = "Trouble workspace"}
    )

    map(
        "n",
        "<Leader>x,",
        "<cmd>lua require('plugs.trouble').toggle_document()<cr>",
        {silent = true, desc = "Trouble document"}
    )

    map(
        "n",
        "<Leader>xk",
        [[<Cmd>call coc#rpc#request('fillDiagnostics', [bufnr('%')])<CR><Cmd>Trouble loclist<CR>]],
        {silent = true, desc = "Trouble loclist"}
    )
end

init()

return M
