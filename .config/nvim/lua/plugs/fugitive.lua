local M = {}

local utils = require("common.utils")
local augroup = utils.augroup
local wk = require("which-key")

local bmap = function(...)
    utils.bmap(0, ...)
end

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
    local info = fn.getqflist({idx = 0, context = 0})
    local idx, ctx = info.idx, info.context
    if idx and ctx and type(ctx.items) == "table" then
        local diff = ctx.items[idx].diff or {}
        if #diff == 1 then
            cmd("abo vert diffs " .. diff[1].filename)
            ex.winc("p")
        end
    end
end

-- TODO: Fix fugitive buffer command autocommand
function M.map()
    bmap("n", "st", ":Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>", {noremap = false, silent = true})
    bmap("n", "<Leader>gb", ":GBrowse<CR>")
end

local function init()
    local bufname = api.nvim_buf_get_name(0)
    if bufname:find("/.git/index$") then
        vim.schedule(
            function()
                cmd(("do fugitive BufReadCmd %s"):format(bufname))
            end
        )
    end

    g.nremap = {
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
        }
    )

    augroup(
        "Fugitive",
        {
            event = "BufReadPost,",
            pattern = "fugitive://*",
            command = "set bufhidden=delete"
        }
    )

    ex.packadd("vim-rhubarb")

    wk.register(
        {
            ["<Leader>gg"] = {[[<Cmd>lua require('plugs.fugitive').index()<CR>]], "Fugitive index"},
            ["<Leader>ge"] = {"<Cmd>Gedit<CR>", "Fugitive Gedit"},
            ["<Leader>gb"] = {"<Cmd>Git blame -w<Bar>winc p<CR>", "Fugitive blame"},
            ["<Leader>gw"] = {
                [[<Cmd>lua require('utils').follow_symlink()<CR><Cmd>Gwrite<CR>]],
                "Fugitive Gwrite"
            },
            ["<Leader>gr"] = {
                [[<Cmd>lua require('utils').follow_symlink()<CR><Cmd>keepalt Gread<Bar>up!<CR>]],
                "Fugitive Gread"
            },
            ["<Leader>gf"] = {"<Cmd>Git fetch --all<CR>", "Fugitive fetch all"},
            ["<Leader>gF"] = {"<Cmd>Git fetch origin<CR>", "Fugitive fetch origin"}
            -- ["<Leader>gp"] = {"<Cmd>Git pull<CR>", "Fugitive pull"},
        }
    )

    wk.register(
        {
            ["<Leader>gC"] = {":Git commit<Space>", "Fugitive commit"},
            -- ["<Leader>gC"] = {":Git commit --amend<Space>", "Fugitive commit (amend)"},
            ["<Leader>gd"] = {":tab Gdiffsplit<Space>", "Fugitive Gdiffsplit"},
            ["<Leader>gt"] = {":Git difftool -y<Space>", "Fugitive difftool"}
        },
        {silent = false}
    )
end

init()

return M
