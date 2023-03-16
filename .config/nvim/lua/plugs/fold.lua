local M = {}

local D = require("dev")
local palette = require("kimbox.palette").colors
local style = require("style")
local hl = require("common.color")
local utils = require("common.utils")
local map = utils.map

local wk = require("which-key")

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local v = vim.v
-- local uv = vim.loop
-- local g = vim.g

---@module "ufo.main"
local ufo
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
    local function get_cur_lnum()
        return api.nvim_win_get_cursor(0)[1]
    end

    local cnt = v.count1
    local wv = utils.save_win_positions(0)
    local cur_l = get_cur_lnum()
    cmd.norm({"m`", bang = true})
    -- local prev_lnum
    -- local prev_lnum_list = {}

    while cnt > 0 do
        if forward then
            -- End of current fold
            cmd("keepj norm! ]z")
        else
            -- End of previous fold
            cmd("keepj norm! zk")
        end
        cur_l = get_cur_lnum()
        if forward then
            -- Top of next fold
            cmd("keepj norm! zj_")
        else
            -- Top of current fold
            cmd("keepj norm! [z_")
        end
        cnt = cnt - 1
    end

    local cur_l1 = get_cur_lnum()
    if cur_l == cur_l1 then
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
    local filler =
        ("•"):rep(target_width - curr_width - strwidth(foldlvl) - strwidth(filler_right) - 1)
    table.insert(new_virt_text, {(" %s"):format(filler), "Comment"})
    table.insert(new_virt_text, {foldlvl, "UFOFoldLevel"})
    table.insert(new_virt_text, {percentage, "ErrorMsg"})
    table.insert(new_virt_text, {suffix, "MoreMsg"})
    table.insert(new_virt_text, {("%s"):format(filler_right), "Comment"})
    return new_virt_text
end

---Setup 'ultra-fold'
M.setup_ufo = function()
    ---@module "ufo.main"
    ufo = D.npcall(require, "ufo")
    if not ufo then
        return
    end

    ufo.setup(
        {
            open_fold_hl_timeout = 360,
            close_fold_kinds = {"imports"}, -- comment, imports, region
            fold_virt_text_handler = handler,
            -- Enable to capture the virtual text for the fold end lnum and assign the
            -- result to `end_virt_text` field of ctx table as 6th parameter in
            -- `fold_virt_text_handler`
            enable_get_fold_virt_text = false,
            -- After the buffer is displayed (opened for the first time), close the
            -- folds whose range with `kind` field is included in this option.
            -- For now, only 'lsp' provider contain 'comment', 'imports' and 'region'
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
                    jumpTop = "gk",
                    jumpBot = "gj",
                    close = "q",
                    switch = "<Tab>",
                    trace = "<CR>"
                }
            },
            provider_selector = function(_bufnr, filetype)
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

local function go_prev_and_peek()
    ufo.goPreviousClosedFold()
    ufo.peekFoldedLinesUnderCursor()
end

local function go_next_and_peek()
    ufo.goNextClosedFold()
    ufo.peekFoldedLinesUnderCursor()
end

---Handle fallback error
---@param bufnr number
---@param err string
---@param providerName string
function M.handle_fallback(bufnr, err, providerName)
    if type(err) == "string" and err:match("UfoFallbackException") then
        return require("ufo").getFolds(bufnr, providerName)
    else
        return require("promise").reject(err)
    end
end

---Set max 'foldlevel'
---@param bufnr number
function M.set_foldlevel(bufnr)
    ufo.getFolds(bufnr, "lsp"):catch(
        function(err)
            return M.handle_fallback(bufnr, err, "treesitter")
        end
    ):catch(
        function(err)
            return M.handle_fallback(bufnr, err, "indent")
        end
    ):finally(
        function()
            -- set foldlevel to max after UFO is initialized
            local max = api.nvim_eval("max(map(range(1, line('$')), 'foldlevel(v:val)'))")
            vim.o.foldlevel = max == 0 and 99 or max
            -- vim.o.foldlevel = max
        end
    )
end

local function init()
    -- vim.opt.fillchars:append("fold:•")
    vim.opt.sessionoptions:append("folds")

    ft_map = {
        zsh = "indent",
        tmux = "indent",
        typescript = {"lsp", "treesitter"},
        vimwiki = "indent",
        luapad = {"lsp", "treesitter"},
        [""] = "",
        man = "",
        git = "",
        floggraph = "",
        neoterm = "",
        floaterm = "",
        toggleterm = "",
        fzf = "",
        telescope = "",
        scratchpad = "",
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

            -- o.foldmethod = "marker"
            -- o.foldmarker = "[[[,]]]"
            -- o.foldmethod = "expr"
            -- o.foldexpr = "nvim_treesitter#foldexpr()"

            vim.o.foldenable = true
            vim.o.foldopen = "block,hor,mark,percent,quickfix,search,tag,undo" -- commands that open a fold
            vim.o.foldcolumn = "1" -- when to draw fold column
            vim.o.foldmarker = "[[[,]]]" -- start and end marker (marker)
            vim.o.foldlevelstart = 99 -- sets 'foldlevel' when editing buffer
            vim.o.foldlevel = 99 -- folds higher than this will be closed (zm, zM, zR)

            -- map({"n", "x"}, "z", [[v:lua.require'common.builtin'.prefix_timeout('z')]], {expr = true})
            map({"n", "x"}, "[z", "<Cmd>norm! [z_<CR>", {desc = "Top open fold (fold levels)"})
            map({"n", "x"}, "]z", "<Cmd>norm! ]z_<CR>", {desc = "Bottom open fold (fold levels)"})

            map({"n", "x"}, "z]", "<Cmd>norm! zj_<CR>", {desc = "Start next fold"})
            map({"n", "x"}, "z[", "<Cmd>norm! zk_<CR>", {desc = "Bottom previous fold"})

            map({"n", "x"}, "zl", "<Cmd>norm! zj_<CR>", {desc = "Next start fold"})
            map(
                "n",
                "zh",
                [[require('ufo').goPreviousStartFold()]],
                {luacmd = true, desc = "Previous start fold"}
            )
            -- map("n", "zl", [[require('plugs.fold').nav_fold(true)]], {luacmd = true, desc = "Next start fold"})
            -- map("n", "z[", [[<Cmd>lua require('plugs.fold').nav_fold(false)<CR>]])
            -- map("n", "z]", [[require('plugs.fold').nav_fold(true)]], {luacmd = true, desc = "Next start fold"})

            map(
                "n",
                "z,",
                [[require('ufo').goPreviousClosedFold()]],
                {luacmd = true, desc = "Previous closed fold"}
            )
            map(
                "n",
                "z.",
                [[require('ufo').goNextClosedFold()]],
                {luacmd = true, desc = "Next closed fold"}
            )

            map({"n", "x"}, "zL", D.ithunk(go_next_and_peek), {desc = "Go next closed fold & peek"})
            map({"n", "x"}, "zH", D.ithunk(go_prev_and_peek), {desc = "Go prev closed fold & peek"})
            map({"n", "x"}, "zK", D.ithunk(ufo.closeFoldsWith), {desc = "Close folds with v:count"})
            map("n", "zR", D.ithunk(ufo.openAllFolds), {desc = "Open all folds (keep 'fdl')"})
            map("n", "zM", D.ithunk(ufo.closeAllFolds), {desc = "Close all folds (keep 'fdl')"})
            -- map("n", "z<", "zR", {desc = "Open all folds: set 'fdl' to max"})
            -- map("n", "z>", "zM", {desc = "Close all folds: set 'fdl' to 0"})

            map(
                "n",
                "z;",
                "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>",
                {silent = true, desc = "Toggle fold"}
            )
            -- "&foldlevel ? 'zM' :'zR'",
            -- [[execute(&foldlevel ? 'norm zM' : 'norm zR')]],
            map(
                "n",
                "z'",
                [[execute((foldclosed(line('.')) < 0) ? 'norm zM' : 'norm zR')]],
                {cmd = true, silent = true, desc = "Toggle all folds"}
            )

            wk.register(
                {
                    ["zf"] = "Create fold operator",
                    ["zF"] = "Create fold for [count] lines",
                    ["zd"] = "Delete one fold at the cursor",
                    ["zD"] = "Delete folds recursively",
                    ["zE"] = "Eliminate all folds",
                    ["zv"] = "Open folds to show cursorline",
                    ["zx"] = "Undo manual, show cursorline, recompute",
                    ["zX"] = "Undo manual, recompute folds",
                    ["zm"] = "Fold more: subtract v:count1 from 'fdl'",
                    -- ["zM"] = "Close all folds: set 'fdl' to 0",
                    -- ["zR"] = "Open all folds: set 'fdl' to max",
                    ["zr"] = "Reduce folding: add v:count1 to 'fdl'",
                    ["zn"] = "Fold none: open all folds",
                    ["zN"] = "Fold normal: all folds remain",
                    ["zi"] = "Invert 'foldenable'"
                }
            )

            wk.register(
                {
                    ["zf"] = "Create fold with selection",
                    ["zd"] = "Delete one fold at the cursor",
                    ["zD"] = "Delete folds recursively",
                    ["zo"] = "Open one level of folds",
                    ["zO"] = "Open all levels of folds",
                    ["zc"] = "Close one level of folds",
                    ["zC"] = "Close all level of folds"
                },
                {mode = "v"}
            )

            -- local bufnr = api.nvim_get_current_buf()
            -- M.set_foldlevel(bufnr)
            -- nvim.autocmd.lmb__SetFoldlevel = {
            --     event = "BufReadPost",
            --     pattern = "*",
            --     -- command = [[let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))]],
            --     command = function(args)
            --         vim.defer_fn(
            --             function()
            --                 M.set_foldlevel(args.buf)
            --             end,
            --             1000
            --         )
            --     end,
            --     desc = "Set 'foldlevel' to max when opening file. Allows 'zr' to work"
            -- }
        end,
        50
    )
end

init()

return M
