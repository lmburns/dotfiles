local M = {}

local utils = require("common.utils")
local map = utils.map

local cmt_utils = require("Comment.utils")
local ts_utils = require("ts_context_commentstring.utils")
local internal = require("ts_context_commentstring.internal")

local wk = require("which-key")

-- local state = {}

-- gcip = paragraph
-- gcw = start next word
-- gc5j = 5 lines down
-- gca} = around curly braces
-- gc} = next blank line

-- gco = start comment next line
-- gcO = previous line
-- gcA = end of line

-- Visual
-- gc = linewise
-- gb = [[ blockwise ]]

function M.setup()
    require("Comment").setup(
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
            -- Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
            -- @type table
            mappings = {
                -- operator-pending mapping
                -- Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
                -- NOTE: These mappings can be changed individually by `opleader` and `toggler` config
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
                local U = require "Comment.utils"

                -- Determine the location where to calculate commentstring from
                local location = nil
                if ctx.ctype == U.ctype.block then
                    location = ts_utils.get_cursor_location()
                elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
                    location = ts_utils.get_visual_start_location()
                end

                -- Detemine whether to use linewise or blockwise commentstring
                local type = ctx.ctype == cmt_utils.ctype.line and "__default" or "__multiline"

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

    -- Can set the type of comment
    require("Comment.ft").set("rescript", {"//%s", "/*%s*/"})
end

local function init()
    M.setup()

    -- map("n", "gl", ":lua require('Comment.api').toggle_current_linewise()<CR>")
    -- map("x", "gl", [[<ESC><CMD>lua require("Comment.api").locked.toggle_linewise_op(vim.fn.visualmode())<CR>]])

    map("n", "<C-.>", ":lua require('Comment.api').toggle_current_linewise()<CR>j")
    -- map("v", "<C-.>", ":lua require('Comment.api').toggle_current_linewise()<CR>'>j")

    map("i", "<C-.>", [[<Esc>:<C-u>lua require('Comment.api').toggle_current_linewise()<CR>]])

    map("x", "<C-.>", [[<ESC><CMD>lua require("Comment.api").locked.toggle_linewise_op(vim.fn.visualmode())<CR>]])

    map(
        "x",
        "<C-A-.>",
        function()
            local selection = utils.get_visual_selection()
            fn.setreg(vim.v.register, selection)
            cmd("normal! gv")
            require("Comment.api").locked.toggle_linewise_op(vim.fn.visualmode())
        end,
        {desc = "Copy text and comment it out"}
    )

    -- wk.register(
    --     {
    --         ["gc"] = "Toggle comment prefix"
    --     },
    --     {mode = "n"}
    -- )
end

init()

return M
