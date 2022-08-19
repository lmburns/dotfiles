local M = {}

local utils = require("common.utils")
local augroup = utils.augroup
local wk = require("which-key")

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api

local bmap = function(...)
    utils.bmap(0, ...)
end

function M.index()
    local bufname = api.nvim_buf_get_name(0)
    if fn.winnr("$") == 1 and bufname == "" then
        cmd.Git()
    else
        cmd("tab Git")
    end
    if bufname == "" then
        cmd("sil! noa bw #")
    end
end

-- placeholder for Git difftool --name-only :)
function M.diff_hist()
    local info = fn.getqflist({idx = 0, context = 0})
    ---@diagnostic disable-next-line:undefined-field
    local idx, ctx = info.idx, info.context
    if idx and ctx and type(ctx.items) == "table" then
        local diff = ctx.items[idx].diff or {}
        if #diff == 1 then
            cmd("abo vert diffs " .. diff[1].filename)
            cmd.winc("p")
        end
    end
end

-- TODO: Fix fugitive buffer command autocommand
function M.map()
    bmap(
        "n",
        "st",
        ":Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>",
        {noremap = false, silent = true, desc = "Gtabedit"}
    )
    bmap("n", "<Leader>gb", ":GBrowse<CR>", {desc = "GBrowse"})
end

local function init()
    local bufname = api.nvim_buf_get_name(0)
    if bufname:find("/.git/index$") then
        vim.schedule(
            function()
                cmd(("doau fugitive BufReadCmd %s"):format(bufname))
            end
        )
    end

    -- How does this work?
    g.nremap = {
        ["d?"] = "d?",
        dv = "dv",
        dp = "dp",
        ds = "ds",
        dh = "dh",
        dq = "",
        d2o = "d2o",
        d3o = "d3o",
        dd = "dd",
        s = "s",
        u = "u",
        O = "T",
        a = "",
        X = "x",
        ["-"] = "a",
        ["*"] = "",
        ["#"] = "",
        ["<C-W>gf"] = "gF",
        ["[m"] = "[f",
        ["]m"] = "]f"
    }

    g.xremap = {s = "S", u = "<C-u>", ["-"] = "a", X = "x"}

    augroup(
        "FugitiveCustom",
        {
            event = "User",
            pattern = {"FugitiveIndex", "FugitiveCommit"},
            command = function()
                require("plugs.fugitive").map()
            end
        },
        {
            event = "BufReadPost",
            pattern = "fugitive://*",
            command = function()
                vim.o.bufhidden = "delete"
            end
        }
    )

    cmd.packadd("vim-rhubarb")

    wk.register(
        {
            ["<LocalLeader>gg"] = {
                [[<Cmd>lua require('plugs.fugitive').index()<CR>]],
                "Fugitive index"
            },
            ["<LocalLeader>ge"] = {"<Cmd>Gedit<CR>", "Fugitive Gedit"},
            ["<LocalLeader>gR"] = {"<Cmd>Gread<CR>", "Fugitive Gread (plain)"},
            ["<LocalLeader>gB"] = {
                "<Cmd>Git blame -w<Bar>winc p<CR>",
                "Fugitive blame split"
            },
            ["<LocalLeader>gw"] = {
                [[<Cmd>lua require('common.utils').follow_symlink()<CR><Cmd>Gwrite<CR>]],
                "Fugitive Gwrite"
            },
            ["<LocalLeader>gW"] = {
                [[<Cmd>lua require('common.utils').follow_symlink("Gwrite")<CR>]],
                "Fugitive Gwrite"
            },
            ["<LocalLeader>gr"] = {
                [[<Cmd>lua require('common.utils').follow_symlink()<CR><Cmd>keepalt Gread<Bar>up!<CR>]],
                "Fugitive Gread"
            },
            ["<LocalLeader>gf"] = {"<Cmd>Git fetch --all<CR>", "Fugitive fetch all"},
            ["<LocalLeader>gF"] = {"<Cmd>Git fetch origin<CR>", "Fugitive fetch origin"}
            -- ["<Leader>gp"] = {"<Cmd>Git pull<CR>", "Fugitive pull"},
        }
    )

    -- nnoremap <silent> ,g, :diffget //2<CR>
    -- nnoremap <silent> ,g. :diffget //3<CR>

    wk.register(
        {
            ["<LocalLeader>gc"] = {":Git commit<Space>", "Fugitive commit"},
            ["<LocalLeader>gC"] = {":Git commit --amend<Space>", "Fugitive commit (amend)"},
            ["<LocalLeader>gd"] = {":tab Gdiffsplit<Space>", "Fugitive Gdiffsplit"},
            ["<LocalLeader>gt"] = {":Git difftool -y<Space>", "Fugitive difftool"}
        },
        {silent = false}
    )
end

init()

return M
