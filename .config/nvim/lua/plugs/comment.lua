local M = {}

local map = require("common.utils").map
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
          extended = false,
        },

        -- Pre-hook, called before commenting the line
        -- @type fun(ctx: Ctx):string
        pre_hook = nil,

        -- Post-hook, called after commenting is done
        -- @type fun(ctx: Ctx)
        post_hook = nil,
      }
  )
end

local function init()
  M.setup()
  map("n", "gl", ":lua require('Comment.api').toggle_current_linewise()<CR>")
  map("n", "<C-_>", ":lua require('Comment.api').toggle_current_linewise()<CR>j")
  map(
      "v", "<C-_>",
      ":lua require('Comment.api').toggle_current_linewise()<CR>'>j"
  )

  map(
      "i", "<C-_>",
      [[<Esc>:<C-u>lua require('Comment.api').toggle_current_linewise()<CR>]]
  )

  map(
      "x", "<C-_>",
      [[<ESC><CMD>lua require("Comment.api").locked.toggle_linewise_op(vim.fn.visualmode())<CR>]]
  )
  map(
      "x", "gl",
      [[<ESC><CMD>lua require("Comment.api").locked.toggle_linewise_op(vim.fn.visualmode())<CR>]]
  )
end

init()

return M
