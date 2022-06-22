local M = {}

local D = require("dev")
local lush = D.npcall(require, "lush")
if not lush then
    return
end

local log = require("common.log")

local ex = nvim.ex
local fn = vim.fn

local colors_path

function M.reload_module(m_name)
    m_name = vim.trim(m_name)
    for p in pairs(package.loaded) do
        if p:sub(1, #m_name) == m_name then
            package.loaded[p] = nil
        end
    end
end

-- if v:vim_did_enter
--     syntax reset
-- endif
function M.dump(name)
    local header =
        ([[
if !(exists('g:colors_name') && g:colors_name ==# '%s')
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = '%s'
]]):format(
        name,
        name
    )

    local theme_path = ("%s/%s.vim"):format(colors_path, name)

    -- RELOAD("lush_theme")
    M.reload_module("lush_theme")
    local ok, res = pcall(require, "lush_theme." .. name)
    if ok then
        local module = res
        ok, res = pcall(lush.compile, module)
        if ok then
            local lines = res
            local fp = assert(io.open(theme_path, "w+"))
            fp:write(header)
            -- fp:write(([[let g:colors_name = '%s'%s]]):format(name, "\n"))
            for _, line in ipairs(lines) do
                fp:write(line, "\n")
            end
            fp:close()
            ex.so(theme_path)
        else
            log.err(res)
        end
    else
        res = type(res) == "table" and res.res or res:match("[^\n]+")
        log.err(res)
    end
end

function M.write_post()
    local fname = fn.expand("<afile>")
    if fname ~= "" then
        local base = fn.fnamemodify(fname, ":t:r")
        M.dump(base)
    end
end

local function init()
    ex.pa("lush.nvim")
    colors_path = ("%s/colors"):format(fn.stdpath("config"))
    fn.mkdir(colors_path, "p")
end

init()

return M
