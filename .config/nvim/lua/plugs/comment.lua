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
local op = require("common.op")
local mpi = require("common.api")
local map = mpi.map

local fn = vim.fn

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
                block = "gbc",
            },
            -- LHS of operator-pending mappings in NORMAL + VISUAL mode
            -- @type table
            opleader = {
                -- line-comment keymap
                line = "gc",
                -- block-comment keymap
                block = "gb",
            },
            ---LHS of extra mappings
            ---@type table
            extra = {
                ---Add comment on the line above
                above = "gcO",
                ---Add comment on the line below
                below = "gco",
                ---Add comment at the end of line
                eol = "gcA",
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
                extended = false,
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

                return internal.calculate_commentstring{
                    key = type,
                    location = location,
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
            doc_width = 100, -- width of the document
            box_width = 60,  -- width of the boxes
            borders = {
                -- symbols used to draw a box
                top = "─",
                bottom = "─",
                left = "│",
                right = "│",
                top_left = "╭",
                top_right = "╮",
                bottom_left = "╰",
                bottom_right = "╯",
            },
            line_width = 70, -- width of the lines
            -- symbols used to draw a line
            line = {
                line = "=",
                -- line_start = "=== ",
                line_start = "=",
                line_end = "=",
            },
            outer_blank_lines = false,     -- insert a blank line above and below the box
            inner_blank_lines = false,     -- insert a blank line above and below the text
            line_blank_line_above = false, -- insert a blank line above the line
            line_blank_line_below = false, -- insert a blank line below the line
        }
    )

    local _ = D.ithunk
    local ms = {"n", "x"}

    map(ms, "<Leader>bb", cb.lcbox, {desc = "L:fix,C:txt (round)"})
    map(ms, "<Leader>bs", _(cb.lcbox, 19), {desc = "L:fix,C:txt (sides)"})
    map(ms, "<Leader>bd", _(cb.lcbox, 7), {desc = "L:fix,C:txt (double)"})
    map(ms, "<Leader>blc", _(cb.lcbox, 13), {desc = "L:fix,C:txt (l-side)"})
    map(ms, "<Leader>bll", cb.llbox, {desc = "L:fix,L:txt (round)"})
    map(ms, "<Leader>blr", _(cb.lrbox, 16), {desc = "L:fix,R:txt (r-side)"})
    map(ms, "<Leader>br", cb.rcbox, {desc = "R:fix,C:txt (round)"})
    map(ms, "<Leader>bR", cb.rcbox, {desc = "R:fix,R:txt (round)"})
    map(ms, "<Leader>bc", cb.ccbox, {desc = "C:fix,C:txt (round)"})

    map(ms, "<Leader>ba", cb.albox, {desc = "L:adapted (round)"})
    map(ms, "<Leader>be", _(cb.albox, 19), {desc = "L:adapted (l-side)"})
    map(ms, "<Leader>bA", cb.acbox, {desc = "C:adapted (round)"})

    -- 20
    map(ms, "<Leader>cc", _(cb.lcbox, 21), {desc = "L:fix, c:txt (top/bot)"})
    map(ms, "<Leader>cb", _(cb.lcbox, 8), {desc = "L:fix, c:txt (t=dbl,s=single)"})
    map(ms, "<Leader>ce", _(cb.lcbox, 9), {desc = "L:fix, c:txt (t=single,s=dbl)"})
    map(ms, "<Leader>ca", _(cb.acbox, 21), {desc = "C:adapted (top/bot)"})

    -- 2 6 7 9 10
    map({"n", "i"}, "<M-w>", _(cb.line, 6), {desc = "Double line"})
    map({"n"}, "<Leader>cn", _(cb.line, 7), {desc = "Double confined line"})
    map({"n"}, "<Leader>ct", _(cb.line, 7), {desc = "Simple heavy line"})
    map({"n"}, "<Leader>cT", _(cb.line, 7), {desc = "Heavy confined line"})

    map("n", "<Leader>b?", cb.catalog, {desc = "CommentBox catalog"})
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
        [[<Esc><Cmd>lua require("Comment.api").locked("toggle.linewise")(vim.fn.visualmode())<CR>]]
    )

    map(
        "x",
        "<C-A-.>",
        function()
            local selection = op.get_visual_selection()
            fn.setreg(vim.v.register, selection)
            require("Comment.api").locked("toggle.linewise")(fn.visualmode())
        end,
        {desc = "Copy text and comment it out"}
    )

    -- FIX: Pastes below
    map("n", "g1p", "<Cmd>norm! gcA<Esc>p<CR>", {desc = "Paste as comment at EOL"})

    wk.register(
        {
            ["gc"] = "Toggle comment prefix",
            ["gb"] = "Toggle block comment prefix",
            ["gcc"] = "Toggle comment",
            ["gbc"] = "Toggle block comment",
            ["gco"] = "Start comment on line below",
            ["gcO"] = "Start comment on line above",
            ["gcA"] = "Start comment at end of line",
        },
        {mode = "n"}
    )
end

init()

return M
