local M = {}

local D = require("dev")
local comment = D.npcall(require, "Comment")
if not comment then
    return
end

local wk = require("which-key")
local utils = require("common.utils")
local map = utils.map

local ft = require("Comment.ft")
local U = require("Comment.utils")

if not D.npcall(require, "nvim-treesitter") then
    return
end

local ts_utils = require("ts_context_commentstring.utils")
local internal = require("ts_context_commentstring.internal")

-- local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

-- TODO: Maybe create an issue
-- Would like to ignore certain lines on comment
-- And ignore others on uncomment

function M.setup()
    comment.setup(
        {
            -- Add a space b/w comment and the line
            -- @type boolean
            padding = true,
            -- Whether the cursor should stay at its position
            -- NOTE: This only affects NORMAL mode mappings and doesn't work with dot-repeat
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
            -- @type fun(ctx: Ctx):string
            pre_hook = function(ctx)
                -- Detemine whether to use linewise or blockwise commentstring
                local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

                -- Determine the location where to calculate commentstring from
                -- Comment out nested languages using correct comment character
                local location = nil
                if ctx.ctype == U.ctype.blockwise then
                    location = ts_utils.get_cursor_location()
                elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
                    location = ts_utils.get_visual_start_location()
                end

                return internal.calculate_commentstring(
                    {
                        key = type,
                        location = location
                    }
                )
            end,
            -- Post-hook, called after commenting is done
            -- @type fun(ctx: Ctx)
            post_hook = nil

            -- post_hook = function(ctx)
            --     -- lprint(ctx)
            --     if ctx.range.scol == -1 then
            --         -- do something with the current line
            --     else
            --         -- print(vim.inspect(ctx), ctx.range.srow, ctx.range.erow, ctx.range.scol, ctx.range.ecol)
            --         if ctx.range.ecol > 400 then
            --             ctx.range.ecol = 1
            --         end
            --         if ctx.cmotion > 1 then
            --             -- 322 324 0 2147483647
            --             vim.fn.setpos("'<", {0, ctx.range.srow, ctx.range.scol})
            --             vim.fn.setpos("'>", {0, ctx.range.erow, ctx.range.ecol})
            --             vim.cmd([[exe "norm! gv"]])
            --         end
            --     end
            -- end

            -- post_hook = function(ctx)
            --     vim.schedule(
            --         function()
            --             if state and state.marks and #state.marks > 0 then
            --                 vim.api.nvim_buf_set_mark(0, "<", state.marks[1][1], state.marks[1][2], {})
            --                 vim.api.nvim_buf_set_mark(0, ">", state.marks[2][1], state.marks[2][2], {})
            --                 vim.cmd [[normal gv]]
            --                 local c = state.cursor
            --                 local diff =
            --                     #(vim.api.nvim_buf_get_lines(0, c[1] - 1, c[1], true))[1] - state.cursor_line_len
            --                 vim.api.nvim_win_set_cursor(0, {state.cursor[1], state.cursor[2] + diff})
            --                 state = {}
            --             end
            --         end
            --     )
            -- end
        }
    )

    ft.set("rescript", {"//%s", "/*%s*/"})
    ft.set("javascript", {"//%s", "/*%s*/"})
    ft.set("conf", "#%s")
    ft({"go", "rust"}, {"//%s", "/*%s*/"})
end

---Flip the comment modes:
---Example:
--      print("first")               # print("first")
--      print("second")      ==>     # print("second")
--      # print("third")             print("third")
--      # print("fourth")            print("fourth")
---@param opmode string
function M.flip_flop_comment(opmode)
    local vmark_start = vim.api.nvim_buf_get_mark(0, "<")
    local vmark_end = vim.api.nvim_buf_get_mark(0, ">")

    local range = U.get_region(opmode)
    local lines = U.get_lines(range)
    local ctx = {
        ctype = U.ctype.linewise,
        range = range
    }
    local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
    local lcs, rcs = U.unwrap_cstr(cstr)
    local padding = U.get_pad(true)

    local min_indent = -1
    for _, line in ipairs(lines) do
        if not U.is_empty(line) and not U.is_commented(lcs, rcs, padding)(line) then
            local cur_indent = U.indent_len(line)
            if min_indent == -1 or min_indent > cur_indent then
                min_indent = cur_indent
            end
        end
    end

    for i, line in ipairs(lines) do
        local is_commented = U.is_commented(lcs, rcs, padding)(line)
        if line == "" then
        elseif is_commented then
            lines[i] = U.uncommenter(lcs, rcs, padding)(line)
        else
            lines[i] = U.commenter(lcs, rcs, padding, min_indent)(line)
        end
    end
    api.nvim_buf_set_lines(0, range.srow - 1, range.erow, false, lines)

    api.nvim_buf_set_mark(0, "<", vmark_start[1], vmark_start[2], {})
    api.nvim_buf_set_mark(0, ">", vmark_end[1], vmark_end[2], {})
end

local function init()
    M.setup()

    map(
        {"n", "x"},
        "gC",
        [[<Cmd>set operatorfunc=v:lua.require'plugs.comment'.flip_flop_comment<CR>g@]],
        {desc = "Flip comment order"}
    )
    map("n", "<C-.>", "<Cmd>lua require('Comment.api').toggle.linewise.current()<CR>j")
    map("i", "<C-.>", [[<Esc>:<C-u>lua require('Comment.api').toggle.linewise.current()<CR>]])
    map("x", "<C-.>", [[<Esc><Cmd>lua require("Comment.api").locked("toggle.linewise.current")()<CR>]])

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
