-- Add custom notify to yank
require("neoclip").setup(
    {
      history = 10000,
      enable_persistent_history = true,
      continious_sync = false,
      db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
      filter = nil,
      preview = true,
      default_register = "+",
      content_spec_column = false,
      on_paste = { set_reg = false },
      on_replay = { set_reg = false },
      keys = {
        telescope = {
          i = {
            select = "<C-n>",
            paste = "<C-j>",
            paste_behind = "<c-k>",
            delete = "<c-d>", -- delete an entry
            replay = "<c-q>",
            custom = {
              ["<C-y>"] = function(opts)
                require("common.yank").yank_reg(
                    vim.v.register, opts.entry.contents[1]
                )
              end,
              ["<CR>"] = function(opts)
                require("common.yank").yank_reg(
                    vim.v.register, opts.entry.contents[1]
                )
              end,
            },
          },
          n = {
            select = "<C-n>",
            paste = "p",
            paste_behind = "P",
            replay = "q",
            delete = "d",
            custom = {
              ["<CR>"] = function(opts)
                require("common.yank").yank_reg(
                    vim.v.register, opts.entry.contents[1]
                )
              end,

            },
          },
        },
      },
    }
)

require("telescope").load_extension("neoclip")
