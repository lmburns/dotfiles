local map = require("common.utils").map

require("high-str").setup(
    {
      verbosity = 0,
      highlight_colors = {
        color_0 = { "#F06431", "smart" },
        color_1 = { "#DC3958", "smart" },
        color_2 = { "#088649", "smart" },
        color_3 = { "#F79A32", "smart" },
        color_4 = { "#889B4A", "smart" },
        color_5 = { "#98676A", "smart" },
        color_6 = { "#7E5053", "smart" },
        color_7 = { "#418292", "smart" },
        color_8 = { "#8AB1B0", "smart" },
        color_9 = { "#7d5c34", "smart" },
      },
    }
)

map("v", "<F3>", ":<C-u>HSHighlight 1<CR>", { silent = true })
map("v", "<F4>", ":<C-u>HSRmHighlight 1<CR>", { silent = true })
