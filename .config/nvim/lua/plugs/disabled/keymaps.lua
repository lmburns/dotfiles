-- TODO: Use this or remove it
local nest = require("nest")

nest.applyKeymaps {
  { mode = "i", { { "jk", "<Esc>" }, { "kj", "<Esc>" } } },

  {
    mode = "n",
    {
      {
        "<C-",
        { { "-S-Right>", ":bnext<CR>" }, { "-S-Left>", ":bprevious<CR>" } },
      },
    },
  },
}
