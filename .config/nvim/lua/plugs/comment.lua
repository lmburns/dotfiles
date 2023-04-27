local M = {}

local D = require("dev")
local comment = D.npcall(require, "Comment")
if not comment then
    return
end

if not D.npcall(require, "ts_context_commentstring") then
    return
end

local wk = require("which-key")
local utils = require("common.utils")
local mpi = require("common.api")
local map = mpi.map

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local fs = vim.fs
local g = vim.g

local ft = require("Comment.ft")
local U = require("Comment.utils")
local ts_utils = require("ts_context_commentstring.utils")
local internal = require("ts_context_commentstring.internal")

-- local state = {}

-- TODO: Doc comments

---Setup `comment.nvim`
function M.setup()
    comment.setup(
        {
            -- Add a space b/w comment and the line
            -- @type boolean
            padding = true,
            -- Whether the cursor should stay at its position
            -- @type boolean
            sticky = true,
            -- Lines to be ignored while comment/uncomment.
            -- Could be a regex string or a function that returns a regex string.
            -- Example: Use '^$' to ignore empty lines
            -- @type string|function
            -- ignore = "^$",
            ignore = nil,
            -- LHS of toggle mappings in NORMAL + VISUAL mode
            -- @type table
            toggler = {
                -- line-comment keymap
                line = "gcc",
                -- block-comment keymap
                block = "gbc"
            },
            -- LHS of operator-pending mappings in NORMAL + VISUAL mode
            -- @type table
            opleader = {
                -- line-comment keymap
                line = "gc",
                -- block-comment keymap
                block = "gb"
            },
            ---LHS of extra mappings
            ---@type table
            extra = {
                ---Add comment on the line above
                above = "gcO",
                ---Add comment on the line below
                below = "gco",
                ---Add comment at the end of line
                eol = "gcA"
            },
            -- Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
            -- @type table
            mappings = {
                -- operator-pending mapping
                -- Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
                basic = true,
                -- extra mapping
                -- Includes `gco`, `gcO`, `gcA`
                extra = true,
                -- extended mapping
                -- Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
                extended = false
            },
            -- Pre-hook, called before commenting the line
            -- @type fun(ctx: CommentCtx):string
            ---@return string?
            pre_hook = function(ctx)
                -- Determine whether to use linewise or blockwise commentstring
                local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

                -- Determine the location where to calculate commentstring from
                local location = nil
                if ctx.ctype == U.ctype.blockwise then
                    location = {ctx.range.srow - 1, ctx.range.scol}
                elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
                    location = ts_utils.get_visual_start_location()
                end

                -- if ctx.range.ecol > 400 then
                --     ctx.range.ecol = 1
                -- end

                -- if ctx.cmotion >= 3 and ctx.cmotion <= 5 then
                --     local cr, cc = unpack(api.nvim_win_get_cursor(0))
                --     local m = {
                --         ["<"] = {ctx.range.srow, ctx.range.scol},
                --         [">"] = {ctx.range.erow, ctx.range.ecol}
                --     }
                --     if cr == m["<"][1] then
                --         m = {
                --             ["<"] = {ctx.range.erow, ctx.range.scol},
                --             [">"] = {ctx.range.srow, ctx.range.ecol}
                --         }
                --     end
                --     state.marks = m
                --     state.cursor = {cr, cc}
                --     state.cursor_line_len = #fn.getline(".")
                -- else
                --     state = {}
                -- end

                return internal.calculate_commentstring {
                    key = type,
                    location = location
                }
            end,
            -- Post-hook, called after commenting is done
            -- @type fun(ctx: CommentCtx)
            -- post_hook = function(ctx)
            --     vim.schedule(
            --         function()
            --             if state and state.marks and #(vim.tbl_keys(state.marks)) > 0 then
            --                 nvim.mark["<"] = state.marks["<"]
            --                 nvim.mark[">"] = state.marks[">"]
            --                 cmd [[norm! gv]]
            --                 local cr, cc = unpack(state.cursor)
            --                 local diff = #fn.getline(".") - state.cursor_line_len
            --                 mpi.set_cursor(0, cr, cc + diff)
            --                 state = {}
            --             end
            --         end
            --     )
            -- end
        }
    )

    ft.set("rescript", {"//%s", "/*%s*/"})
    ft.set("javascript", {"//%s", "/*%s*/"})
    ft.set("typescript", {"//%s", "/*%s*/"})
    ft.set("conf", "#%s")
    ft.set("vim", '"%s')
    ft({"go", "rust"}, {"//%s", "/*%s*/"})
end

-- ╓                                                          ╖
-- ║                        CommentBox                        ║
-- ╙                                                          ╜
function M.comment_box()
    local cb = D.npcall(require, "comment-box")
    if not cb then
        return
    end

    cb.setup(
        {
            doc_width = 80, -- width of the document
            box_width = 60, -- width of the boxes
            borders = {
                -- symbols used to draw a box
                top = "─",
                bottom = "─",
                left = "│",
                right = "│",
                top_left = "╭",
                top_right = "╮",
                bottom_left = "╰",
                bottom_right = "╯"
            },
            line_width = 70, -- width of the lines
            line = {
                -- symbols used to draw a line
                line = "─",
                line_start = "─",
                line_end = "─"
            },
            outer_blank_lines = false, -- insert a blank line above and below the box
            inner_blank_lines = false, -- insert a blank line above and below the text
            line_blank_line_above = false, -- insert a blank line above the line
            line_blank_line_below = false -- insert a blank line below the line
        }
    )

    local _ = D.ithunk

    -- 21 20 19 18 7
    map({"n", "v"}, "<Leader>bb", cb.lcbox, {desc = "Left fixed, center text (round)"})
    map({"n", "v"}, "<Leader>bs", _(cb.lcbox, 19), {desc = "Left fixed, center text (sides)"})
    map({"n", "v"}, "<Leader>bd", _(cb.lcbox, 7), {desc = "Left fixed, center text (double)"})
    map({"n", "v"}, "<Leader>blc", _(cb.lcbox, 13), {desc = "Left fixed, center text (side)"})
    map({"n", "v"}, "<Leader>bll", cb.llbox, {desc = "Left fixed, left text (round)"})
    map({"n", "v"}, "<Leader>blr", cb.lrbox, {desc = "Left fixed, right text (side)"})
    map({"n", "v"}, "<Leader>br", cb.rcbox, {desc = "Right fixed, center text (round)"})
    map({"n", "v"}, "<Leader>bR", cb.rcbox, {desc = "Right fixed, right text (round)"})

    map({"n", "v"}, "<Leader>ba", cb.albox, {desc = "Left adapted (round)"})
    map({"n", "v"}, "<Leader>be", _(cb.albox, 19), {desc = "Left adapted (side)"})
    map({"n", "v"}, "<Leader>bA", cb.acbox, {desc = "Center adapted (round)"})

    map({"n", "v"}, "<Leader>bc", cb.ccbox, {desc = "Center fixed, center text (round)"})

    map({"n", "v"}, "<Leader>cc", _(cb.lcbox, 21), {desc = "Left fixed, center text (top/bottom)"})
    map({"n", "v"}, "<Leader>cb", _(cb.lcbox, 8), {desc = "Left fixed, center text (thick)"})
    map({"n", "v"}, "<Leader>ca", _(cb.acbox, 21), {desc = "Center adapted (top/bottom)"})

    -- 2 6 7
    map({"n", "i"}, "<M-w>", _(cb.cline, 6), {desc = "Insert thick line"})

    map("n", "<Leader>b?", cb.catalog, {desc = "Comment box catalog"})
end

local function init()
    M.setup()

    -- map(
    --     {"n", "x"},
    --     "gC",
    --     [[<Cmd>set operatorfunc=v:lua.require'plugs.comment'.flip_flop_comment<CR>g@]],
    --     {desc = "Flip comment order"}
    -- )

    map("n", "<C-.>", "<Cmd>lua require('Comment.api').toggle.linewise.current()<CR>j")
    map("i", "<C-.>", [[<C-o><Cmd>lua require('Comment.api').toggle.linewise.current()<CR>]])
    map(
        "x",
        "<C-.>",
        [[<Esc><Cmd>lua require("Comment.api").locked("toggle.linewise.current")()<CR>]]
    )

    map(
        "x",
        "<C-A-.>",
        function()
            local selection = utils.get_visual_selection()
            fn.setreg(vim.v.register, selection)
            utils.normal("n", "gv")
            -- cmd("normal! gv")
            require("Comment.api").locked("toggle.linewise.current")()
        end,
        {desc = "Copy text and comment it out"}
    )

    map("n", "g1p", "<Cmd>norm! gcA<Esc>p<CR>", {desc = "Paste as comment at EOL"})

    wk.register(
        {
            ["gc"] = "Toggle comment prefix",
            ["gb"] = "Toggle block comment prefix",
            ["gcc"] = "Toggle comment",
            ["gbc"] = "Toggle block comment",
            ["gco"] = "Start comment on line below",
            ["gcO"] = "Start comment on line above",
            ["gcA"] = "Start comment at end of line"
        },
        {mode = "n"}
    )
end

init()

return M
