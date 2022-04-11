local M = {}

function M.setup()
  require("pretty-fold").setup(
      {
        -- fill_char = "•",
        -- fill_char = " ",
        -- process_comment_signs = "delete",
        -- sections = {
        --   left = { "content" },
        --   right = {
        --     " ",
        --     "number_of_folded_lines",
        --     ": ",
        --     "percentage",
        --     " ",
        --     function(config)
        --       return config.fill_char:rep(3)
        --     end,
        --   },
        -- },
        -- keep_indentation = true,

        --   fill_char = "━",
        keep_indentation = false,
        sections = {
          left = {
            "━━",
            function()
              return string.rep(">", vim.v.foldlevel)
            end,
            "━━┫",
            "content",
            "┣",
          },
          right = {
            "┫ ",
            "number_of_folded_lines",
            ": ",
            "percentage",
            " ┣━━",
          },
        },
      }
  )

  require("pretty-fold.preview").setup({ key = "l" })
end

local function init()
  vim.opt.fillchars:append("fold:•")
  vim.defer_fn(
      function()
        require("common.fold")
        M.setup()
      end, 50
  )
end

init()

return M
