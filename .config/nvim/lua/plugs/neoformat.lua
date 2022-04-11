local M = {}

local utils = require("common.utils")
local autocmd = utils.autocmd
local map = utils.map
local coc = require("plugs.coc")
local gittool = require("common.gittool")

local function save_doc(bufnr)
  vim.schedule(
      function() api.nvim_buf_call(bufnr, function() cmd("sil! up") end) end
  )
end

local function neoformat()
  cmd("Neoformat")
  cmd("sil! up")
end

function M.format_doc()
  gittool.root_exe(
      function()
        if coc.did_init() then
          local bufnr = api.nvim_get_current_buf()
          local err, res = coc.a2sync("hasProvider", { "format" }, 2000)
          if not err and res == true then
            fn.CocActionAsync(
                "format", "", function(e, _)
                  if e ~= vim.NIL then
                    api.nvim_buf_call(bufnr, function()
                      neoformat()
                    end)
                  else
                    save_doc(bufnr)
                  end
                end
            )
          else
            neoformat()
          end
        else
          neoformat()
        end
      end
  )
end

function M.format_selected(mode)
  if not coc.did_init() then
    return
  end

  gittool.root_exe(
      function()
        local err, res = coc.a2sync(
            "hasProvider", { mode and "formatRange" or "format" }, 2000
        )
        if not err and res == true then
          local bufnr = api.nvim_get_current_buf()
          fn.CocActionAsync(
              mode and "formatSelected" or "format", mode, function(e, _)
                if e ~= vim.NIL then
                  vim.notify(e, vim.log.levels.WARN)
                else
                  save_doc(bufnr)
                end
              end
          )
        end
      end
  )
end

local function init()
  g.neoformat_basic_format_retab = 1
  g.neoformat_basic_format_trim = 1
  g.neoformat_basic_format_align = 1

  g.neoformat_enabled_lua = { "luaformat" }
  g.neoformat_enabled_python = { "black" }
  g.neoformat_enabled_python = { "black" }
  g.neoformat_enabled_zsh = { "expand" }
  g.neoformat_enabled_java = { "prettier" }

  g.neoformat_enabled_yaml = { "prettier" }
  g.neoformat_yaml_prettier = {
    exe = "prettier",
    args = { "--stdin-filepath", "\"%:p\"", "--tab-width=2" },
    stdin = 1,
  }

  g.neoformat_enabled_sql = { "sqlformatter" }
  g.neoformat_sql_sqlformatter = {
    exe = "sql-formatter",
    args = { "--indent", "4" },
    stdin = 1,
  }

  g.neoformat_enabled_json = { "jq" }
  g.neoformat_json_jq = {
    exe = "jq",
    args = { "--indent", "4", "--tab" },
    stdin = 1,
  }

  map("n", ";ff", [[:lua require('plugs.neoformat').format_doc()<CR>]])
  map(
      "x", ";ff",
      [[:lua require('plugs.neoformat').format_selected(vim.fn.visualmode())<CR>]]
  )

  -- Formatting options that are better than coc's :Format
  -- autocmd(
  --     "formatting", {
  --       [[FileType lua        nmap ;ff :Neoformat! lua    luaformat<CR>]],
  --       [[FileType java       nmap ;ff :Neoformat! java   prettier<CR>]],
  --       [[FileType perl       nmap ;ff :Neoformat! perl<CR>]],
  --       [[FileType sh         nmap ;ff :Neoformat! sh<CR>]],
  --       [[FileType python     nmap ;ff :Neoformat! python black<CR>]],
  --       [[FileType md,vimwiki nmap ;ff :Neoformat!<CR>]],
  --       [[FileType zsh        nmap ;ff :Neoformat  expand<CR>]],
  --     }, true
  -- )
end

init()

return M