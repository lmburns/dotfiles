local M = {}

local map = require("common.utils").map

function M.setup()
    require("trouble").setup(
        {
            position = "bottom", -- position of the list can be: bottom, top, left, right
            height = 15, -- height of the trouble list when position is top or bottom
            width = 50, -- width of the list when position is left or right
            icons = true, -- use devicons for filenames
            mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
            fold_open = "", -- icon used for open folds
            fold_closed = "", -- icon used for closed folds
            group = true, -- group results by file
            padding = true, -- add an extra new line on top of the list
            action_keys = {
                -- key mappings for actions in the trouble list
                -- map to {} to remove a mapping, for example:
                -- close = {},
                close = "q", -- close the list
                cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
                refresh = "r", -- manually refresh
                jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
                open_split = {"<c-x>"}, -- open buffer in new split
                open_vsplit = {"<c-v>"}, -- open buffer in new vsplit
                open_tab = {"<c-t>"}, -- open buffer in new tab
                jump_close = {"o"}, -- jump to the diagnostic and close the list
                toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
                toggle_preview = "P", -- toggle auto_preview
                hover = "K", -- opens a small popup with the full multiline message
                preview = "p", -- preview the diagnostic location
                close_folds = {"zC", "zc"}, -- close all folds
                open_folds = {"zR", "zo"}, -- open all folds
                toggle_fold = {"zA", "za"}, -- toggle fold of current file
                previous = "k", -- preview item
                next = "j" -- next item
            },
            indent_lines = true, -- add an indent guide below the fold icons
            auto_open = false, -- automatically open the list when you have diagnostics
            auto_close = false, -- automatically close the list when you have no diagnostics
            auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
            auto_fold = false, -- automatically fold a file trouble list at creation
            -- auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
            signs = {
                -- icons / text used for a diagnostic
                error = "",
                warning = "",
                hint = "",
                information = "",
                other = "﫠"
            },
            use_diagnostic_signs = true -- enabling this will use the signs defined in your lsp client
        }
    )
end

local function init()
    M.setup()

    map(
        "n",
        "]v",
        function()
            require("trouble").next({skip_groups = true, jump = true})
        end,
        {desc = "Trouble next"}
    )

    map(
        "n",
        "[v",
        function()
            require("trouble").previous({skip_groups = true, jump = true})
        end,
        {desc = "Trouble previous"}
    )

    map(
        "n",
        "]V",
        function()
            require("trouble").last({skip_groups = true, jump = true})
        end,
        {desc = "Trouble last"}
    )

    map(
        "n",
        "[V",
        function()
            require("trouble").first({skip_groups = true, jump = true})
        end,
        {desc = "Trouble first"}
    )

    map("n", "<Leader>xd", "<cmd>TroubleToggle coc_definitions<cr>", {silent = true, desc = "Trouble definitions"})
    map("n", "<Leader>xR", "<cmd>TroubleToggle coc_references<cr>", {silent = true, desc = "Trouble references"})

    map(
        "n",
        "<Leader>xr",
        "<cmd>TroubleToggle coc_references_used<cr>",
        {silent = true, desc = "Trouble references used"}
    )

    map(
        "n",
        "<Leader>xy",
        "<cmd>TroubleToggle coc_type_definitions<cr>",
        {silent = true, desc = "Trouble type definition"}
    )

    map(
        "n",
        "<Leader>xi",
        "<cmd>TroubleToggle coc_implementations<cr>",
        {silent = true, desc = "Trouble implementations"}
    )

    map(
        "n",
        "<Leader>x;",
        "<cmd>TroubleToggle coc_workspace_diagnostics<cr>",
        {silent = true, desc = "Trouble workspace"}
    )

    map(
        "n",
        "<Leader>x,",
        "<cmd>TroubleToggle coc_document_diagnostics<cr>",
        {silent = true, desc = "Trouble workspace"}
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