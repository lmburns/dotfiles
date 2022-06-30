local M = {}

local utils = require("common.utils")
local map = utils.map

local hlslens
local config
local lens_backup
local n_keymap

local bmap = function(...)
    utils.bmap(0, ...)
end

local override_lens = function(render, plist, nearest, idx, r_idx)
    local _ = r_idx
    local lnum, col = unpack(plist[idx])

    local text, chunks
    if nearest then
        text = ("[%d/%d]"):format(idx, #plist)
        chunks = {{" ", "Ignore"}, {text, "VM_Extend"}}
    else
        text = ("[%d]"):format(idx)
        chunks = {{" ", "Ignore"}, {text, "HlSearchLens"}}
    end
    render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
end

function M.start()
    if hlslens then
        config = require("hlslens.config")
        lens_backup = config.override_lens
        config.override_lens = override_lens
        hlslens.start(true)
    end
end

function M.exit()
    if hlslens then
        config.override_lens = lens_backup
        hlslens.start(true)
    end

    -- Reset the mapping on exit
    -- Something happened where now I cannot get the correct binding
    -- map("n", "n", n_keymap, {silent = true})
    -- map("n", "n", "n", {silent = true})
    map(
        "n",
        "n",
        ("%s%s%s"):format(
            [[<Cmd>execute('norm! ' . v:count1 . 'nzv')<CR>]],
            [[<Cmd>lua require('hlslens').start()<CR>]],
            [[<Cmd>lua require("specs").show_specs()<CR>]]
        )
    )
end

function M.mappings()
    ex.PackerLoad("nvim-hlslens")
    -- n_keymap = utils.get_keymap("n", "n").rhs
    bmap("n", "n", "<C-n>", {silent = true, noremap = false})
    bmap("n", "<Esc>", "<Plug>(VM-Exit)")
    bmap("i", "<CR>", [[coc#pum#visible() ? "\<C-y>" : "\<Plug>(VM-I-Return)"]], {expr = true, noremap = false})
end

local function init()
    local ok, res = pcall(require, "hlslens")
    if ok then
        hlslens = res
    end
end

init()

return M
