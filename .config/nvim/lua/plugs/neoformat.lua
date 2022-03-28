local utils = require("common.utils")
local autocmd = utils.autocmd

g.neoformat_basic_format_retab = 1
g.neoformat_basic_format_trim = 1
g.neoformat_basic_format_align = 1

-- Formatting options that are better than coc's :Format
autocmd(
    "formatting", {
      [[FileType lua        nmap ;ff :Neoformat! lua    luaformat<CR>]],
      [[FileType java       nmap ;ff :Neoformat! java   prettier<CR>]],
      [[FileType perl       nmap ;ff :Neoformat! perl<CR>]],
      [[FileType sh         nmap ;ff :Neoformat! sh<CR>]],
      [[FileType python     nmap ;ff :Neoformat! python black<CR>]],
      [[FileType md,vimwiki nmap ;ff :Neoformat!<CR>]],
      [[FileType zsh        nmap ;ff :Neoformat  expand<CR>]],
    }, true
)
