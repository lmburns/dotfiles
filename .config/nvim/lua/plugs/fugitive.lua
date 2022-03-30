local M = {}

local utils = require("common.utils")
local create_augroup = utils.create_augroup
local bmap = function(...) utils.bmap(0, ...) end

function M.index()
  local bufname = api.nvim_buf_get_name(0)
  if fn.winnr("$") == 1 and bufname == "" then
    cmd("Git")
  else
    cmd("tab Git")
  end
  if bufname == "" then
    cmd("sil! noa bw #")
  end
end

-- placeholder for Git difftool --name-only :)
function M.diff_hist()
  local info = fn.getqflist({ idx = 0, context = 0 })
  local idx, ctx = info.idx, info.context
  if idx and ctx and type(ctx.items) == "table" then
    local diff = ctx.items[idx].diff or {}
    if #diff == 1 then
      cmd("abo vert diffs " .. diff[1].filename)
      cmd("winc p")
    end
  end
end

function M.map()
  bmap(
      "n", "st", ":Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>",
      { noremap = false, silent = true }
  )
  bmap("n", "<Leader>gb", ":GBrowse<CR>")
end

local function init()
  local bufname = api.nvim_buf_get_name(0)
  if bufname:find("/.git/index$") then
    vim.schedule(
        function() cmd(("do fugitive BufReadCmd %s"):format(bufname)) end
    )
  end

  vim.g.nremap = {
    ["d?"] = "s?",
    dv = "sv",
    dp = "sp",
    ds = "sh",
    dh = "sh",
    dq = "",
    d2o = "s2o",
    d3o = "s3o",
    dd = "ss",
    s = "<C-s>",
    u = "<C-u>",
    O = "T",
    a = "",
    X = "x",
    ["-"] = "a",
    ["*"] = "",
    ["#"] = "",
    ["<C-W>gf"] = "gF",
    ["[m"] = "[f",
    ["]m"] = "]f",
  }
  vim.g.xremap = { s = "S", u = "<C-u>", ["-"] = "a", X = "x" }

  api.nvim_create_autocmd(
      { "User", "FugitiveIndex", "FugitiveCommit" }, {
        callback = function() require("plugs.fugitive").map() end,
        group = create_augroup("FugitiveCustom", true),
      }
  )

  -- cmd [[
  --       aug FugitiveCustom
  --           au!
  --           au User FugitiveIndex,FugitiveCommit lua require('plugs.fugitive').map()
  --       aug end
  --   ]]

  cmd [[packadd vim-rhubarb]]
end

init()

return M
