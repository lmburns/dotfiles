local M = {}

local D = require("dev")
local palette = require("kimbox.palette").colors
local style = require("style")
local utils = require("common.utils")
local hl = require("common.color")
-- local coc = require("plugs.coc")
-- local augroup = utils.augroup
local map = utils.map

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local v = vim.v
-- local uv = vim.loop
-- local g = vim.g

local ft_map

---Set the `foldtext` (i.e., the text displayed for a fold)
---@return string
M.foldtext = function()
    local fs, fe = v.foldstart, v.foldend
    local fs_lines = api.nvim_buf_get_lines(0, fs - 1, fe - 1, false)
    local fs_line = fs_lines[1]
    for _, line in ipairs(fs_lines) do
        if line:match("%w") then
            fs_line = line
            break
        end
    end
    local pad = " "
    fs_line = utils.expandtab(fs_line, vim.bo.ts)
    local winid = api.nvim_get_current_win()
    local textoff = fn.getwininfo(winid)[1].textoff
    local width = api.nvim_win_get_width(0) - textoff
    local fold_info = (" %d lines %s +- "):format(1 + fe - fs, v.foldlevel)
    local padding = pad:rep(width - #fold_info - api.nvim_strwidth(fs_line))
    return fs_line .. padding .. fold_info
end

---Navigate folds
---@param forward boolean should move forward?
M.nav_fold = function(forward)
    local cnt = v.count1
    local wv = utils.save_win_positions()
    cmd.norm({"m`", bang = true})

    local cur_l, cur_c
    while cnt > 0 do
        if forward then
            cmd("keepj norm! ]z")
        else
            cmd("keepj norm! zk")
        end
        cur_l, cur_c = unpack(api.nvim_win_get_cursor(0))
        if forward then
            cmd("keepj norm! zj_")
        else
            cmd("keepj norm! [z_")
        end
        cnt = cnt - 1
    end

    local cur_l1, cur_c1 = unpack(api.nvim_win_get_cursor(0))
    if cur_l == cur_l1 and cur_c == cur_c1 then
        if forward or fn.foldclosed(cur_l) == -1 then
            wv.restore()
        end
    end
end

---Wrap a fold command to highlight the text when opened
---@param c string the suffix to the 'z' in the fold command (e.g., 'c' for `zc`)
M.with_highlight = function(c)
    local cnt = v.count1
    local fostart = fn.foldclosed(".")
    local foend
    if fostart > 0 then
        foend = fn.foldclosedend(".")
    end

    hl.set("MyFoldHighlight", {bg = "#5e452b"})

    local ok = pcall(cmd, ("norm! %dz%s"):format(cnt, c))
    if ok then
        if fn.foldclosed(".") == -1 and fostart > 0 and foend > fostart then
            utils.highlight(0, "MyFoldHighlight", fostart - 1, foend, nil, 400)
        end
    end
end

---Return the number of lines that are folded
---@return string
M.number_of_folded_lines = function()
    return ("%d lines"):format(v.foldend - v.foldstart + 1)
end

---Get the percentage of the file that the fold takes up
---@return string
M.percentage = function(startl, endl)
    -- local folded_lines = v.foldend - v.foldstart + 1
    local folded_lines = endl - startl + 1
    local total_lines = api.nvim_buf_line_count(0)
    local pnum = math.floor(100 * folded_lines / total_lines)
    local str = tostring(pnum)
    if pnum == 0 then
        str = tostring(100 * folded_lines / total_lines):sub(2, 3)
    -- elseif pnum < 10 then
    --     pnum = " " .. pnum
    --     pnum = pnum
    end
    return str .. "%"
end

---Force the fold on the current line to immediately open or close.
---Unlike za and zo it only takes one command to open any fold.
---Unlike zO it does not open recursively, it only opens the current fold.
M.open_fold = function()
    if fn.foldclosed(".") == -1 then
        cmd.foldclose()
    else
        while fn.foldclosed(".") ~= -1 do
            cmd.foldopen()
        end
    end
end

---Customize the handler to display virtual text for UFO
---@param virt_text table
---@param lnum number
---@param end_lnum number
---@param width number
---@return table
local function handler(virt_text, lnum, end_lnum, width, truncate)
    local strwidth = api.nvim_strwidth
    local new_virt_text = {}
    local percentage = (" %s"):format(M.percentage(lnum, end_lnum))
    local suffix = ("  %d "):format(end_lnum - lnum)
    local target_width = width - strwidth(suffix) - strwidth(percentage)
    local curr_width = 0

    for _, chunk in ipairs(virt_text) do
        local chunk_text = chunk[1]
        local chunk_width = strwidth(chunk_text)
        if target_width > curr_width + chunk_width then
            table.insert(new_virt_text, chunk)
        else
            chunk_text = truncate(chunk_text, target_width - curr_width)
            local hl_group = chunk[2]
            table.insert(new_virt_text, {chunk_text, hl_group})
            chunk_width = strwidth(chunk_text)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curr_width + chunk_width < target_width then
                suffix = suffix .. (" "):rep(target_width - curr_width - chunk_width)
            end
            break
        end
        curr_width = curr_width + chunk_width
    end

    local foldlvl = ("+"):rep(v.foldlevel)
    local filler_right = ("•"):rep(3)
    -- This extra 1 comes from the space added on the line below the following
    local filler = ("•"):rep(target_width - curr_width - strwidth(foldlvl) - strwidth(filler_right) - 1)
    table.insert(new_virt_text, {(" %s"):format(filler), "Comment"})
    table.insert(new_virt_text, {foldlvl, "UFOFoldLevel"})
    table.insert(new_virt_text, {percentage, "ErrorMsg"})
    table.insert(new_virt_text, {suffix, "MoreMsg"})
    table.insert(new_virt_text, {("%s"):format(filler_right), "Comment"})
    return new_virt_text
end

---Setup 'ultra-fold'
M.setup_ufo = function()
    local ufo = D.npcall(require, "ufo")
    if not ufo then
        return
    end

    ufo.setup(
        {
            open_fold_hl_timeout = 360,
            fold_virt_text_handler = handler,
            -- Enable to capture the virtual text for the fold end lnum and assign the
            -- result to `end_virt_text` field of ctx table as 6th parameter in
            -- `fold_virt_text_handler`
            enable_fold_end_virt_text = false,
            -- After the buffer is displayed (opened for the first time), close the
            -- folds whose range with `kind` field is included in this option.
            -- For now, only 'lsp' provider contain 'comment', 'imports' and 'region'
            close_fold_kinds = {"imports"}, -- comment
            preview = {
                win_config = {
                    border = style.current.border,
                    winhighlight = "Normal:CocFloating",
                    winblend = 5
                },
                mappings = {
                    scrollB = "",
                    scrollF = "",
                    scrollU = "<C-u>",
                    scrollD = "<C-d>",
                    scrollE = "<C-e>",
                    scrollY = "<C-y>",
                    close = "q",
                    switch = "<Tab>",
                    trace = "<CR>"
                }
            },
            ---@diagnostic disable-next-line:unused-local
            provider_selector = function(bufnr, filetype)
                -- return a string type use internal providers
                -- return a string in a table like a string type
                -- return empty string '' will disable any providers
                -- return `nil` will use default value {'lsp', 'indent'}

                -- if you prefer treesitter provider rather than lsp,
                -- return ft_map[filetype] or {'treesitter', 'indent'}
                return ft_map[filetype]
            end
        }
    )
end

local function init()
    -- vim.opt.fillchars:append("fold:•")
    vim.opt.sessionoptions:append("folds")

    ft_map = {
        zsh = "indent",
        tmux = "indent",
        typescript = {"lsp", "treesitter"},
        [""] = "",
        man = "",
        vimwiki = "",
        git = "",
        floggraph = "",
        neoterm = "",
        floaterm = "",
        toggleterm = "",
        fzf = "",
        telescope = "",
        scratchpad = "",
        luapad = "",
        aerial = ""
    }

    vim.defer_fn(
        function()
            hl.plugin(
                "Ufo",
                {
                    UFOFoldLevel = {fg = palette.blue, bold = true},
                    UfoPreviewThumb = {link = "PmenuThumb"},
                    UfoPreviewSbar = {link = "PmenuSbar"}
                }
            )

            M.setup_ufo()

            vim.o.foldenable = true
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldcolumn = "1"
        end,
        50
    )

    -- Folding
    -- map({"n", "x"}, "z", [[v:lua.require'common.builtin'.prefix_timeout('z')]], {expr = true})
    map({"n", "x"}, "[z", "[z_", {desc = "Top of open fold"})
    map({"n", "x"}, "]z", "]z_", {desc = "Bottom of open fold"})
    map({"n", "x"}, "zl", "zj_", {desc = "Top next fold"})
    map({"n", "x"}, "zh", "zk_", {desc = "Bottom previous fold"})

    -- map("n", "za", [[<Cmd>lua require('plugs.fold').with_highlight('a')<CR>]], {silent = false})
    -- map("n", "zA", [[<Cmd>lua require('plugs.fold').with_highlight('A')<CR>]])
    -- map("n", "zo", [[<Cmd>lua require('plugs.fold').with_highlight('o')<CR>]])
    -- map("n", "zO", [[<Cmd>lua require('plugs.fold').with_highlight('O')<CR>]])
    -- map("n", "zv", [[<Cmd>lua require('plugs.fold').with_highlight('v')<CR>]])
    -- map("n", "zR", [[<Cmd>lua require('plugs.fold').with_highlight('CzO')<CR>]])
    -- map("n", "z,", ":lua require('plugs.fold').open_fold()<CR>", {desc = "Open/close all folds under cursor"})

    map("n", "zR", require("ufo").openAllFolds)
    map("n", "zM", require("ufo").closeAllFolds)
    map("n", "z;", "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>", {silent = true})
    map("n", "z'", "&foldlevel ? 'zM' :'zR'", {silent = true, expr = true, desc = "Open/close all folds in file"})

    -- map("n", "z[", [[<Cmd>lua require('plugs.fold').nav_fold(false)<CR>]])
    map("n", "z[", [[require('ufo').goPreviousStartFold()]], {luacmd = true})
    map("n", "z]", [[require('plugs.fold').nav_fold(true)]], {luacmd = true})

    map("n", "z,", [[require('ufo').goPreviousClosedFold()]], {luacmd = true})
    map("n", "z.", [[require('ufo').goNextClosedFold()]], {luacmd = true})
end

init()

return M
