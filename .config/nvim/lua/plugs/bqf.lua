require("common.utils")

if g.colors_name == "one" then
  cmd("hi! link BqfPreviewBorder Parameter")
end

require("bqf").setup(
    {
      auto_enable = true,
      auto_resize_height = true,
      preview = { auto_preview = true, delay_syntax = 50 },
      func_map = {
        split = "<C-s>",
        drop = "o",
        openc = "O",
        tabdrop = "<C-t>",
        pscrollup = "<C-u>",
        pscrolldown = "<C-d>",
      },
      filter = {
        fzf = {
          action_for = {
            ["enter"] = "drop",
            ["ctrl-s"] = "split",
            ["ctrl-t"] = "tab drop",
            ["ctrl-x"] = "",
          },
          extra_opts = { "-d", "│" },
        },
      },
    }
)
