local M = {}

local dev = require("dev")
local palette = require("kimbox.palette").colors
local utils = require("common.utils")
local C = require("common.color")
local coc = require("plugs.coc")
local augroup = utils.augroup
local command = utils.command
local map = utils.map

local ex = nvim.ex
local api = vim.api
local fn = vim.fn
local uv = vim.loop
local cmd = vim.cmd
local v = vim.v

local bl_ft
local coc_loaded_ft
local anyfold_prefer_ft

function M.use_anyfold(bufnr, force)
    local filename = api.nvim_buf_get_name(bufnr)
    local st = uv.fs_stat(filename)
    if st then
        local fsize = st.size
        if force or 0 < fsize and fsize < 131072 then
            if fn.bufwinid(bufnr) == -1 then
                -- cmd(
                --     ("au FoldLoad BufEnter <buffer=%d> ++once %s"):format(
                --         bufnr,
                --         ([[lua require('plugs.fold').use_anyfold(%d)]]):format(bufnr)
                --     )
                -- )
                augroup(
                    {"FoldLoad", false},
                    {
                        event = "BufEnter",
                        buffer = bufnr,
                        once = true,
                        command = function()
                            require("plugs.fold").use_anyfold(bufnr)
                        end
                    }
                )
            else
                api.nvim_buf_call(
                    bufnr,
                    function()
                        utils.cool_echo(("bufnr: %d is using anyfold"):format(bufnr), "WarningMsg")
                        ex.AnyFoldActivate()
                    end
                )
            end
        end
    end
    vim.b[bufnr].loaded_fold = "anyfold"
end

local function apply_fold(bufnr, ranges)
    api.nvim_buf_call(
        bufnr,
        function()
            vim.wo.foldmethod = "manual"

            -- FIXME: This moves the cursor one place to the left if typing starts within
            cmd("norm! zE")

            local fold_cmd = {}
            for _, f in ipairs(ranges) do
                table.insert(fold_cmd, ("%d,%d:fold"):format(f.startLine + 1, f.endLine + 1))
            end
            cmd(table.concat(fold_cmd, "|"))
            vim.wo.foldenable = true
            vim.wo.foldlevel = 99
        end
    )
end

function M.update_fold(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    coc.run_command(
        -- "kvs.fold.foldingRange",
        "ufo.foldingRange",
        {bufnr},
        function(e, r)
            if e == vim.NIL and type(r) == "table" then
                apply_fold(bufnr, r)
            end
        end
    )
end

function M.attach(bufnr, force)
    bufnr = bufnr or api.nvim_get_current_buf()
    if not api.nvim_buf_is_valid(bufnr) or not force and vim.b[bufnr].loaded_fold then
        return
    end

    if vim.g.coc_service_initialized == 1 and not vim.tbl_contains(anyfold_prefer_ft, vim.bo.ft) then
        coc.run_command(
            -- "kvs.fold.foldingRange",
            "ufo.foldingRange",
            {bufnr},
            function(e, r)
                if not force and vim.b[bufnr].loaded_fold then
                    return
                end

                if e == vim.NIL and type(r) == "table" then
                    -- language servers may need time to parse buffer
                    if #r == 0 then
                        local ft = vim.bo[bufnr].ft
                        local loaded = coc_loaded_ft[ft]
                        if not loaded then
                            vim.defer_fn(
                                function()
                                    coc_loaded_ft[ft] = true
                                    M.attach(bufnr)
                                end,
                                2000
                            )
                            return
                        end
                    end
                    local winid = fn.bufwinid(bufnr)
                    if winid == -1 then
                        -- cmd(
                        --     ("au FoldLoad BufEnter <buffer=%d> ++once %s"):format(
                        --         bufnr,
                        --         [[lua require('plugs.fold').update_fold()]]
                        --     )
                        -- )
                        augroup(
                            {"FoldLoad", false},
                            {
                                event = "BufEnter",
                                buffer = bufnr,
                                once = true,
                                command = function()
                                    require("plugs.fold").update_fold()
                                end
                            }
                        )
                    else
                        apply_fold(bufnr, r)
                    end

                    vim.b[bufnr].loaded_fold = "coc"

                    augroup(
                        {"FoldLoad", false},
                        {
                            event = "BufWritePost",
                            buffer = bufnr,
                            command = function()
                                require("plugs.fold").update_fold()
                            end
                        },
                        {
                            event = "BufRead",
                            buffer = bufnr,
                            command = function()
                                vim.defer_fn(require("plugs.fold").update_fold, 100)
                            end
                        }
                    )
                else
                    M.use_anyfold(bufnr, force)
                end
            end
        )
    else
        M.use_anyfold(bufnr, force)
    end
    cmd(("au! FoldLoad * <buffer=%d>"):format(bufnr))
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
    -- vim.wo.foldtext = [[v:lua.require'plugs.fold'.foldtext()]]
end

function M.defer_attach(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    local bo = vim.bo[bufnr]
    if vim.b[bufnr].loaded_fold or vim.tbl_contains(bl_ft, bo.ft) or bo.bt ~= "" then
        return
    end

    local winid = dev.find_win_except_float(bufnr)
    if winid == 0 or not api.nvim_win_is_valid(winid) then
        return
    end
    local wo = vim.wo[winid]
    -- if wo.foldmethod == "diff" or wo.foldmethod == "expr" then
    if wo.foldmethod == "diff" then
        return
    end

    wo.foldmethod = "manual"
    vim.defer_fn(
        function()
            M.attach(bufnr)
        end,
        1000
    )
end

function M.foldtext()
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

function M.nav_fold(forward)
    local cnt = v.count1
    local wv = fn.winsaveview()
    cmd([[norm! m`]])
    local cur_l, cur_c
    while cnt > 0 do
        if forward then
            -- cmd("keepj norm! ]z")
            ex.keepj(ex.norm_("]z"))
        else
            -- cmd("keepj norm! zk")
            ex.keepj(ex.norm_("zk"))
        end
        cur_l, cur_c = unpack(api.nvim_win_get_cursor(0))
        if forward then
            -- cmd("keepj norm! zj_")
            ex.keepj(ex.norm_("zj_"))
        else
            -- cmd("keepj norm! [z_")
            ex.keepj(ex.norm_("[z_"))
        end
        cnt = cnt - 1
    end

    local cur_l1, cur_c1 = unpack(api.nvim_win_get_cursor(0))
    if cur_l == cur_l1 and cur_c == cur_c1 then
        if forward or fn.foldclosed(cur_l) == -1 then
            fn.winrestview(wv)
        end
    end
end

function M.with_highlight(c)
    local cnt = v.count1
    local fostart = fn.foldclosed(".")
    local foend
    if fostart > 0 then
        foend = fn.foldclosedend(".")
    end

    C.set_hl("MyFoldHighlight", {bg = "#5e452b"})
    -- ex.hi("MyFoldHighlight guibg=#5e452b")

    local ok = pcall(cmd, ("norm! %dz%s"):format(cnt, c))
    if ok then
        if fn.foldclosed(".") == -1 and fostart > 0 and foend > fostart then
            utils.highlight(0, "MyFoldHighlight", fostart - 1, foend, nil, 400)
        end
    end
end

function M.setup_prettyfold()
    if not pcall(require, "pretty-fold") then
        return
    end

    require("pretty-fold").setup(
        {
            fill_char = "•",
            keep_indentation = true,
            remove_fold_markers = true,
            process_comment_signs = "delete",
            sections = {
                left = {"content"},
                right = {
                    "+",
                    function()
                        return string.rep("-", v.foldlevel)
                    end,
                    " ",
                    "number_of_folded_lines",
                    ": ",
                    "percentage",
                    " ",
                    function(config)
                        return config.fill_char:rep(3)
                    end
                }
            },
            -- List of patterns that will be removed from content foldtext section.
            stop_words = {
                "@brief%s*" -- (for C++) Remove '@brief' and all spaces after.
            },
            add_close_pattern = true, -- true, 'last_line' or false
            matchup_patterns = {
                {"{", "}"},
                {"%(", ")"}, -- % to escape lua pattern char
                {"%[", "]"} -- % to escape lua pattern char
            },
            ft_ignore = {"neorg"}
        }
    )

    require("pretty-fold").ft_setup(
        "lua",
        {
            matchup_patterns = {
                {"^%s*do$", "end"}, -- do ... end blocks
                {"^%s*if", "end"}, -- if ... end
                {"^%s*for", "end"}, -- for
                {"function%s*%(", "end"}, -- 'function( or 'function (''
                {"{", "}"},
                {"%(", ")"}, -- % to escape lua pattern char
                {"%[", "]"} -- % to escape lua pattern char
            }
        }
    )

    require("pretty-fold.preview").setup(
        {
            default_keybindings = false,
            border = "rounded"
        }
    )

    local keymap_amend = require("keymap-amend")
    local mapping = require("pretty-fold.preview").mapping
    keymap_amend("n", "l", mapping.show_close_preview_open_fold)
end

---Customize the handler to display virtual text for UFO
---@param virt_text table
---@param lnum number
---@param end_lnum number
---@param width number
---@return table
local handler = function(virt_text, lnum, end_lnum, width, truncate)
    local new_virt_text = {}
    local percentage = (" %s"):format(M.percentage(lnum, end_lnum))
    local suffix = ("  %d "):format(end_lnum - lnum)
    local target_width = width - api.nvim_strwidth(suffix) - api.nvim_strwidth(percentage)
    local curr_width = 0

    for _, chunk in ipairs(virt_text) do
        local chunk_text = chunk[1]
        local chunk_width = api.nvim_strwidth(chunk_text)
        if target_width > curr_width + chunk_width then
            table.insert(new_virt_text, chunk)
        else
            chunk_text = truncate(chunk_text, target_width - curr_width)
            local hl_group = chunk[2]
            table.insert(new_virt_text, {chunk_text, hl_group})
            chunk_width = api.nvim_strwidth(chunk_text)
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
        ("•"):rep(target_width - curr_width - api.nvim_strwidth(foldlvl) - api.nvim_strwidth(filler_right) - 1)
    table.insert(new_virt_text, {(" %s"):format(filler), "Comment"})
    table.insert(new_virt_text, {foldlvl, "UFOFoldLevel"})
    table.insert(new_virt_text, {percentage, "ErrorMsg"})
    table.insert(new_virt_text, {suffix, "MoreMsg"})
    table.insert(new_virt_text, {("%s"):format(filler_right), "Comment"})
    return new_virt_text
end

---Return the number of lines that are folded
---@return string
function M.number_of_folded_lines()
    return ("%d lines"):format(v.foldend - v.foldstart + 1)
end

---Get the percentage of the file that the fold takes up
---@return string
function M.percentage(startl, endl)
    -- local folded_lines = v.foldend - v.foldstart + 1
    local folded_lines = endl - startl + 1
    local total_lines = api.nvim_buf_line_count(0)
    local pnum = math.floor(100 * folded_lines / total_lines)
    if pnum == 0 then
        pnum = tostring(100 * folded_lines / total_lines):sub(2, 3)
    -- elseif pnum < 10 then
    --     pnum = " " .. pnum
    --     pnum = pnum
    end
    return pnum .. "%"
end

---Setup 'ultra-fold'
M.setup_ufo = function()
    require("ufo").setup(
        {
            open_fold_hl_timeout = 360,
            fold_virt_text_handler = handler
        }
    )
end

local function init()
    vim.opt.fillchars:append("fold:•")
    g.anyfold_fold_display = 0
    g.anyfold_identify_comments = 0
    g.anyfold_motion = 0

    vim.defer_fn(
        function()
            C.set_hl("UFOFoldLevel", {fg = palette.blue, bold = true})
            M.setup_ufo()
            -- M.setup_prettyfold()
        end,
        50
    )

    -- blacklist
    bl_ft = {
        "",
        "man",
        "vimwiki",
        "markdown",
        "git",
        "floggraph",
        "neoterm",
        "floaterm",
        "toggleterm",
        "fzf",
        "telescope",
        "scratchpad",
        "luapad",
        "aerial"
    }
    coc_loaded_ft = {}
    anyfold_prefer_ft = {"vim"}

    -- local parsers = require("nvim-treesitter.parsers")
    -- local configs = parsers.get_parser_configs()
    --
    -- augroup(
    --     "lmb__TreesitterFold",
    --     {
    --         event = "FileType",
    --         pattern = table.concat(
    --             vim.tbl_map(
    --                 function(ft)
    --                     return configs[ft].filetype or ft
    --                 end,
    --                 parsers.available_parsers()
    --             ),
    --             ","
    --         ),
    --         command = function()
    --             vim.opt_local.foldmethod = "expr"
    --             vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    --         end
    --     }
    -- )

    augroup(
        "FoldLoad",
        {
            event = "FileType",
            pattern = "*",
            command = function()
                require("plugs.fold").defer_attach(tonumber(fn.expand("<abuf>")))
            end
        }
    )

    command(
        "Fold",
        function()
            require("plugs.fold").attach(nil, true)
        end,
        {nargs = 0}
    )

    map("n", ";fo", "Fold", {cmd = true, desc = "Manually fold"})

    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        M.defer_attach(bufnr)
    end
end

init()

return M
