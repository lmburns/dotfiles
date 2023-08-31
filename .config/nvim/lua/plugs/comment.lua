---@module 'plugs.comment'
local M = {}

local F = Rc.F
local comment = F.npcall(require, "Comment")
if not comment then
    return
end

local it = Rc.F.ithunk
local map = Rc.api.map
local op = Rc.lib.op
local wk = require("which-key")

local fn = vim.fn

local ft = require("Comment.ft")
local U = require("Comment.utils")

-- local state = {}

-- TODO: Doc comments

---Setup `comment.nvim`
function M.setup()
    comment.setup({
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
        toggler = {line = "gcc", block = "gbc"},
        -- LHS of operator-pending mappings in NORMAL + VISUAL mode
        ---@type table
        opleader = {line = "gc", block = "gb"},
        ---LHS of extra mappings
        ---@type table
        extra = {above = "gcO", below = "gco", eol = "gcA"},
        -- Create operator-pending & extended mappings for NORMAL + VISUAL mode
        ---@type table
        mappings = {
            -- Operator-pending (`gcc`, `gc[cnt]{motion}`, `gcb`, `gb[cnt]{motion}`)
            basic = true,
            -- `gco`, `gcO`, `gcA`
            extra = true,
        },
        -- Pre-hook, called before commenting the line
        ---@param ctx CommentCtx
        ---@return string?
        pre_hook = function(ctx)
            local ts_utils = require("ts_context_commentstring.utils")
            local internal = require("ts_context_commentstring.internal")

            -- Determine whether to use linewise or blockwise commentstring
            local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

            -- Determine the location where to calculate commentstring from
            local location = nil
            if ctx.ctype == U.ctype.blockwise then
                location = {ctx.range.srow - 1, ctx.range.scol}
            elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
                location = ts_utils.get_visual_start_location()
            end

            return internal.calculate_commentstring {
                key = type,
                location = location,
            }
        end,
    })

    ft.set("rescript", {"// %s", "/* %s */"})
    ft.set("javascript", {"// %s", "/* %s */"})
    ft.set("typescript", {"// %s", "/* %s */"})
    ft.set("conf", "# %s")
    ft.set("vim", '" %s')
    ft({"go", "rust"}, {"// %s", "/* %s */"})
end

-- ╓                                                          ╖
-- ║                        CommentBox                        ║
-- ╙                                                          ╜
function M.comment_box()
    local cb = F.npcall(require, "comment-box")
    if not cb then
        return
    end

    cb.setup({
        doc_width = 80, -- width of the document
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
            line = "─",
            line_start = "─",
            line_end = "─",
        },

        outer_blank_lines = false,     -- insert a blank line above and below the box
        inner_blank_lines = false,     -- insert a blank line above and below the text
        line_blank_line_above = false, -- insert a blank line above the line
        line_blank_line_below = false, -- insert a blank line below the line
    })

    local cat = require("comment-box.catalog")
    local lines = cat.lines
    table.insert(lines, {
        line = "=",
        line_start = "=",
        line_end = "=",
    })
    table.insert(lines, {
        line = "=",
        line_start = "=== ",
        line_end = "=",
    })
    table.insert(lines, {
        line = "=",
        line_start = "=== ",
        line_end = " [[[",
    })
    table.insert(lines, {
        line = "━",
        line_start = "━━━ ",
        line_end = "━",
    })

    local ms = {"n", "x"}

    map(ms, "<Leader>bb", it(cb.lcbox, 01), {desc = "L:fix,C:txt (round)"})
    map(ms, "<Leader>bi", it(cb.lcbox, 10), {desc = "L:fix,C:txt (ascii)"})
    map(ms, "<Leader>bc", it(cb.ccbox, 01), {desc = "C:fix,C:txt (round)"})
    map(ms, "<Leader>bs", it(cb.lcbox, 19), {desc = "L:fix,C:txt (sides)"})
    map(ms, "<Leader>bd", it(cb.lcbox, 07), {desc = "L:fix,C:txt (double)"})

    map(ms, "<Leader>cc", it(cb.lcbox, 21), {desc = "L:fix,C:txt (top/bot)"})

    map(ms, "<Leader>ba", it(cb.albox, 01), {desc = "L:adapted (round)"})
    map(ms, "<Leader>bA", it(cb.acbox, 01), {desc = "C:adapted (round)"})
    map(ms, "<Leader>be", it(cb.albox, 19), {desc = "L:adapted (l-side)"})

    -- 20
    map(ms, "<Leader>cb", it(cb.lcbox, 8), {desc = "L:fix,C:txt (t=dbl,s=single)"})
    map(ms, "<Leader>ce", it(cb.lcbox, 9), {desc = "L:fix,C:txt (t=single,s=dbl)"})
    map(ms, "<Leader>ca", it(cb.acbox, 21), {desc = "C:adapted (top/bot)"})

    map(ms, "<Leader>br", it(cb.rcbox, 01), {desc = "R:fix,C:txt (round)"})
    map(ms, "<Leader>bR", it(cb.rrbox, 01), {desc = "R:fix,R:txt (round)"})
    map(ms, "<Leader>blc", it(cb.lcbox, 13), {desc = "L:fix,C:txt (l-side)"})
    map(ms, "<Leader>bll", it(cb.llbox, 01), {desc = "L:fix,L:txt (round)"})
    map(ms, "<Leader>blr", it(cb.lrbox, 16), {desc = "L:fix,R:txt (r-side)"})

    --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    -- map(ms, "<Leader>tcc", it(cb.ccbox, 01), {desc = "C:fix,C:txt (round)"})
    -- map(ms, "<Leader>tll", it(cb.llbox, 01), {desc = "L:fix,L:txt (round)"})
    -- map(ms, "<Leader>trr", it(cb.rrbox, 01), {desc = "R:fix,R:txt (round)"})
    --
    -- map(ms, "<Leader>tlc", it(cb.lcbox, 01), {desc = "L:fix,C:txt (round)"})
    -- map(ms, "<Leader>tls", it(cb.lcbox, 19), {desc = "L:fix,C:txt (sides)"})
    -- map(ms, "<Leader>tld", it(cb.lcbox, 07), {desc = "L:fix,C:txt (double)"})
    -- map(ms, "<Leader>tlj", it(cb.lcbox, 09), {desc = "L:fix,C:txt (t=single,s=dbl)"})
    -- map(ms, "<Leader>tlk", it(cb.lcbox, 08), {desc = "L:fix,C:txt (t=dbl,s=single)"})
    -- map(ms, "<Leader>tlh", it(cb.lcbox, 13), {desc = "L:fix,C:txt (l-side)"})
    -- map(ms, "<Leader>tlb", it(cb.lcbox, 21), {desc = "L:fix,C:txt (top/bot)"})
    --
    -- map(ms, "<Leader>tlr", it(cb.lrbox, 16), {desc = "L:fix,R:txt (r-side)"})
    --
    -- map(ms, "<Leader>trc", it(cb.rcbox, 01), {desc = "R:fix,C:txt (round)"})
    --
    -- map(ms, "<Leader>tal", it(cb.albox, 01), {desc = "L:adapted (round)"})
    -- map(ms, "<Leader>tac", it(cb.acbox, 01), {desc = "C:adapted (round)"})
    -- map(ms, "<Leader>tah", it(cb.albox, 19), {desc = "L:adapted (l-side)"})
    -- map(ms, "<Leader>tab", it(cb.acbox, 21), {desc = "C:adapted (top/bot)"})

    -- 2 6 7 9 10
    map({"n", "i"}, "<M-w>", it(cb.line, 2), {desc = "Simple heavy line"})
    map({"n", "i"}, "<C-M-w>", it(cb.line, 11), {desc = "Equals line"})
    map({"n", "i"}, "<M-S-w>", it(cb.line, 13), {desc = "Equals line & fold"})
    map({"i"}, "<M-a>", it(cb.line, 6), {desc = "Double line"})
    map({"n"}, "<Leader>cn", it(cb.line, 7), {desc = "Double confined line"})
    map({"n"}, "<Leader>ct", it(cb.line, 6), {desc = "Double line"})
    map({"n"}, "<Leader>cT", it(cb.line, 4), {desc = "Heavy confined line"})

    map("n", "<Leader>b?", cb.catalog, {desc = "CommentBox catalog"})
end

local function init()
    M.setup()

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

    map("n", "g1p", "gcA<Esc>gcp", {noremap = false, desc = "Paste as comment at EOL"})

    wk.register({
        ["gc"] = "Toggle comment prefix",
        ["gb"] = "Toggle block comment prefix",
        ["gcc"] = "Toggle comment",
        ["gbc"] = "Toggle block comment",
        ["gco"] = "Start comment on line below",
        ["gcO"] = "Start comment on line above",
        ["gcA"] = "Start comment at end of line",
    })
end

init()

return M
