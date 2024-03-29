---@module 'plugs.fzf'
local M = {}

local utils = Rc.shared.utils
local map = Rc.api.map
local augroup = Rc.api.augroup
local command = Rc.api.command
local render = Rc.lib.render

local lazy = require("usr.lazy")
local coc = lazy.require("plugs.coc")
local mru = require("usr.plugs.mru")
local wk = require("which-key")

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g

local default_preview_window

---@param opts FzfRunOpts|FzfWrapRet
function M.fzf_run(opts)
    return fn["fzf#run"](opts)
end

---@param opts FzfRunOpts
---@return FzfWrapRet
function M.fzf_wrap(opts)
    return fn["fzf#wrap"](opts)
end

---@param opts FzfRunOpts
---@param ... string preview_args
function M.fzf_preview(opts, ...)
    return fn["fzf#vim#with_preview"](opts, ...)
end

-- fzf#shellescape
-- fzf#vim#_uniq       fzf#vim#_format_buffer  fzf#vim#_buflisted_sorted
-- fzf#vim#_lines      fzf#vim#_recent_files
-- fzf#vim#buffers     fzf#vim#windows
-- fzf#vim#files       fzf#vim#locate          fzf#vim#gitfiles
-- fzf#vim#lines       fzf#vim#buffer_lines
-- fzf#vim#history     fzf#vim#command_history fzf#vim#search_history
-- fzf#vim#buffer_tags fzf#vim#tags            fzf#vim#helptags
-- fzf#vim#maps        fzf#vim#commands        fzf#vim#marks
-- fzf#vim#colors      fzf#vim#snippets        fzf#vim#filetypes
-- fzf#vim#commits     fzf#vim#buffer_commits
-- fzf#vim#grep        fzf#vim#complete

---@param term? string
---@param no_ignore? boolean
---@param fnames? boolean
function M.rg(term, no_ignore, fnames) --{{{
    term = fn.shellescape(term or "")
    local nth, with_nth, delim = "", "", ""
    if term then
        with_nth = "--with-nth 1.."
        if fnames then
            nth = "--nth 1,4.."
        else
            nth = "--nth 4.."
        end
        delim = "--delimiter :"
    end
    ---@diagnostic disable-next-line: cast-local-type
    no_ignore = no_ignore and "" or "--no-ignore"

    local rg_cmd = table.concat({
        "rg",
        "--line-number",
        "--column",
        "--no-heading",
        "--smart-case",
        "--hidden",
        "--follow",
        "--color=always",
        "-g '!.git/' ",
        no_ignore,
        "--",
        term,
    }, " ")

    local args = {
        options = table.concat({
            '--prompt="Search in files> "',
            "--preview-window nohidden",
            delim,
            with_nth,
            nth,
        }, " "),
    }

    local prev = M.fzf_preview(args)
    fn["fzf#vim#grep"](rg_cmd, 1, prev)
end --}}}

local function build_opt(opts)
    local preview_args = g.fzf_preview_window or default_preview_window
    return M.fzf_preview(opts, unpack(preview_args))
end

local function do_action(expect, path, bufnr, lnum, col)
    local action = g.fzf_action or {}
    local jump_cmd = action[expect] or "edit"
    local bi
    if jump_cmd == "drop" then
        if not bufnr then
            bufnr = fn.bufadd(path)
            vim.bo[bufnr].buflisted = true
        end
        bi = fn.getbufinfo(bufnr)
        if #bi == 1 and #bi[1].windows == 0 then
            api.nvim_set_current_buf(bufnr)
            return
        end
    end

    local function jump_path(p)
        cmd(("%s %s"):format(jump_cmd, fn.fnameescape(p)))
    end

    if path == "" then
        if bufnr and bufnr > 0 and api.nvim_buf_is_valid(bufnr) then
            local tmpfile = fn.tempname()
            local tmp_bufnr = fn.bufadd(tmpfile)
            if jump_cmd:match("drop") then
                bi = bi or fn.getbufinfo(bufnr)
                if #bi == 1 then
                    local winids = bi[1].windows
                    if #winids > 0 then
                        fn.win_gotoid(winids[1])
                        cmd(("keepalt b %d"):format(tmp_bufnr))
                    else
                        jump_path(tmpfile)
                    end
                end
            else
                jump_path(tmpfile)
            end
            cmd(("keepalt b %d"):format(bufnr))
            cmd(("noa bw %d"):format(tmp_bufnr))
        end
    else
        jump_path(path)
    end

    if lnum then
        col = col or 1
        Rc.api.set_cursor(0, lnum, col - 1)
    end
end

local function format_files(b_list, m_list)
    local max_bufnr = 0
    local b_names = {}
    for _, b in ipairs(b_list) do
        b_names[b.name] = true
        if max_bufnr < b.bufnr then
            max_bufnr = b.bufnr
        end
    end
    local max_digit = math.floor(math.log10(max_bufnr)) + 1
    local cur_bufnr, alt_bufnr = api.nvim_get_current_buf(), fn.bufnr("#")
    local fmt = "%s:%d\t%d\t%s[%s]\t%s"
    local out = {}
    for _, b in ipairs(b_list) do
        local bufnr = b.bufnr
        local bt = vim.bo[bufnr].bt
        if not _j({"help", "quickfix", "terminal", "prompt"}):contains(bt) then
            local name = b.name
            local lnum = b.lnum
            local readonly = vim.bo[bufnr].readonly
            local modified = b.changed == 1
            local flag = ""
            if modified then
                flag = render.ansi.Statement:format("+ ")
            elseif readonly then
                flag = render.ansi.Special:format("- ")
            end

            local sname = name == "" and "[No name]" or fn.fnamemodify(name, ":~:.")
            if bufnr == cur_bufnr then
                sname = render.ansi.Directory:format(sname)
            elseif bufnr == alt_bufnr then
                sname = render.ansi.Constant:format(sname)
            end

            sname = flag .. sname
            local bufnr_str = render.ansi.Number:format(tostring(bufnr))
            local digit = math.floor(math.log10(bufnr)) + 1
            local padding = (" "):rep(max_digit - digit)
            local o_str = fmt:format(name, lnum, lnum, padding, bufnr_str, sname)

            table.insert(out, o_str)
        end
    end

    fmt = "%s:1\t1\t" .. (" "):rep(max_digit + 2) .. "\t%s"
    for _, m in ipairs(m_list) do
        if not b_names[m] then
            local sname = fn.fnamemodify(m, ":~:.")
            local o_str = fmt:format(m, sname)
            table.insert(out, o_str)
        end
    end
    return out
end

function M.files()
    local cur_bufnr = api.nvim_get_current_buf()
    local b_list =
        _j(fn.getbufinfo({buflisted = 1})):map(
            function(b)
                return {
                    bufnr = b.bufnr,
                    name = b.name,
                    lnum = b.lnum,
                    lastused = b.lastused,
                    changed = b.changed,
                }
            end
        ):sort(
            function(a, b)
                return a.lastused > b.lastused
            end
        )

    local m_list = mru.list()
    local header = #b_list > 0 and b_list[1].bufnr == cur_bufnr and "1" or "0"
    local opts = {
        options = {
            "+m",
            "--prompt",
            "Files> ",
            "--tiebreak",
            "index",
            "--header-lines",
            header,
            "--ansi",
            "-d",
            "\t",
            "--tabstop",
            "1",
            "--with-nth",
            "3..",
            "--preview-window",
            "+{2}/2",
        },
    }
    opts = build_opt(opts)
    opts.name = "files"
    opts.source = format_files(b_list, m_list)
    opts["sink*"] = function(lines)
        if #lines ~= 2 then
            return
        end
        local expect = lines[1]
        local g1, _, g3 = unpack(vim.split(lines[2], "\t"))
        local path = g1:match("^(.*):%d+$")
        local bufnr = tonumber(g3:match("%[(%d+)%]$"))

        do_action(expect, path, bufnr)
    end
    fn.FzfWrapper(opts)
end

-- TODO: Modify these for my fzf functions
local function format_outline(symbols, bufnr)
    if type(symbols) ~= "table" or #symbols == 0 then
        return
    end
    local out = {}
    local hl_map = {
        Function = "Function",
        Method = "Function",
        Interface = "Structure",
        Struct = "Structure",
        Class = "Structure",
    }
    --   kind = "Function",
    --   level = 0,
    --   name = "M.fzf_run",
    --   range = {
    --     ["end"] = {
    --       character = 3,
    --       line = 40
    --     },
    --     start = {
    --       character = 0,
    --       line = 38
    --     }
    --   }

    -- local fmt = "%s:%d\t%d\t%d\t%s\t    %s%s"
    -- local fmt = "%s%-32s│%5d:%-3d│%s%s%s"
    local fmt = "%s:%d\t%d\t%d\t%s%s\t    %s%s"
    local name = api.nvim_buf_get_name(bufnr)

    for _, s in ipairs(symbols) do
        local i = require("aerial.config").get_icon(bufnr, s.kind)
        local rs, re = s.range.start, s.range["end"]
        local lnum, col = rs.line + 1, rs.character + 1
        local k = s.kind
        local icon = i and render.ansi[hl_map[k] or "@constructor"]:format(i) or ""
        local kind = render.ansi[hl_map[k] or "@constructor"]:format(("%-10s"):format(k))
        local level = s.level > 0 and render.ansi.NonText:format(("| "):rep(s.level)) or ""
        table.insert(out, fmt:format(
            name,
            lnum,
            lnum,
            col,
            icon,
            kind,
            level,
            s.name
        ))

        --  bufnr = bufnr,
        --  lnum = lnum,
        --  col = col,
        --  end_lnum = re.line + 1,
        --  end_col = re.character + 1,
    end
    return out
end

function M.outline()
    require("async")(function()
        local bufnr = api.nvim_get_current_buf()
        local p = coc.runCommand(
            "kvs.symbol.docSymbols", bufnr,
            {"Function", "Method", "Interface", "Struct", "Class"}
        ):thenCall(function(s)
            return format_outline(s, bufnr)
        end)

        local opts = {
            options = {
                "+m",
                "--prompt",
                "Outline> ",
                "--tiebreak",
                "index",
                "--ansi",
                "-d",
                "\t",
                "--tabstop",
                "1",
                "--with-nth",
                "4..",
                "--preview-window",
                "+{2}/2",
            },
        }
        opts = build_opt(opts)
        opts.name = "outline"
        opts.source = await(p)
        opts["sink*"] = function(lines)
            if #lines ~= 2 then
                return
            end
            local expect = lines[1]
            local g1, g2, g3 = unpack(vim.split(lines[2], "\t"))
            local path = g1:match("^(.*):%d+$")
            local lnum, col = tonumber(g2), tonumber(g3)
            do_action(expect, path, nil, lnum, col)
        end
        fn.FzfWrapper(opts)
    end)
end

-- function M.cmdhist()
--     local opts = {
--         name = "history-command",
--         source = cmdhist.list(),
--         ["sink*"] = function(ret)
--             local key, cmdl = unpack(ret)
--             if key == "ctrl-y" then
--                 fn.setreg(vim.v.register, cmdl)
--             else
--                 fn.histadd(":", cmdl)
--                 cmdhist.store()
--                 if key == "ctrl-e" then
--                     cmd("redraw")
--                     api.nvim_feedkeys(":" .. utils.termcodes["<Up>"], "n", false)
--                 else
--                     api.nvim_feedkeys((":" .. cmdl .. utils.termcodes["<CR>"]), "", false)
--                 end
--             end
--         end,
--         options = {
--             "+m",
--             "--prompt",
--             "Hist: ",
--             "--tiebreak",
--             "index",
--             "--expect",
--             "ctrl-e,ctrl-y"
--         }
--     }
--     fn.FzfWrapper(opts)
-- end

---TODO: Get this to work
function M.copyq()
    local source =
        fn.systemlist(
            [[copyq eval -- 'tab("&clipboard"); for(i=size(); i>0; --i) print(str(read(i-1)) + "\n");' | tac]]
        )

    -- local fzf_complete = fn["fzf#vim#complete"]
    local opts = {
        source = source,
        options = {"+m", "--prompt", "Copyq> ", "--tiebreak", "index"},
        -- Get the reducer to work as well
        reducer = function(line)
            -- return fn.substitute(line, [[^ *[0-9]\+ ]], "", "")
            return fn.substitute(line[0], [[s]], "XXX", "g")
        end,
    }

    fn.FzfWrapper(opts)
end

-- map("i", "<A-p>", "<Cmd>lua R('plugs.fzf').copyq()<CR>")

function M.resize_preview_layout()
    local layout = g.fzf_layout.window
    if vim.o.columns * layout.width - 2 > 100 then
        g.fzf_preview_window = {"right:50%,border-left"}
    else
        if vim.o.lines * layout.height - 2 > 25 then
            g.fzf_preview_window = {"down:50%,border-top"}
        else
            g.fzf_preview_window = {"down:50%,border-top,hidden"}
        end
    end
end

function M.prepare_ft()
    -- TODO there's a bug for neovim's floating window for cursorline when split window, keep
    -- cursorline option of fzf's window on as a workaround
    vim.wo.cul = true
    for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
        local bt = vim.bo[api.nvim_win_get_buf(winid)].bt
        if bt == "quickfix" then
            return
        end
    end

    require("usr.lib.shadowwin").create()
    nvim.autocmd.lmb_FzfFt = {
        {
            event = "BufWipeout",
            buffer = api.nvim_get_current_buf(),
            command = function()
                require("usr.lib.shadowwin").close()
            end,
        },
        {
            event = "VimResized",
            buffer = api.nvim_get_current_buf(),
            command = function()
                require("usr.lib.shadowwin").resize()
            end,
        }
    }
end

local function init()
    g.rg_highlight = "true"
    g.rg_format = "%f:%l:%c:%m,%f:%l:%m"

    -- g.fzf_history_dir = "~/.local/share/fzf-history"
    -- g.fzf_layout = { window = "call FloatingFZF()" }
    g.fzf_layout = {
        window = {
            width = 0.8,
            height = 0.8,
            highlight = "Comment",
            border = "rounded",
            relative = true,
        },
    }
    g.fzf_action = {
        ["ctrl-t"] = "tab drop",
        ["ctrl-s"] = "split",
        ["ctrl-m"] = "edit",
        ["alt-v"] = "vsplit",
        ["alt-t"] = "tabnew",
        ["alt-x"] = "split",
    }

    vim.env.FZF_PREVIEW_PREVIEW_BAT_THEME = "kimbox"
    g.fzf_vim_opts = {options = {"--no-separator", "--history=/dev/null", "--reverse"}}
    g.fzf_commands_expect = "enter"
    g.fzf_buffers_jump = 1 -- jump to existing window if possible
    g.fzf_preview_window = {"right:50%:+{2}-/2,nohidden", "?"}

    g.fzf_preview_quit_map = 1
    g.fzf_preview_use_dev_icons = 1
    g.fzf_preview_dev_icon_prefix_string_length = 3
    g.fzf_preview_dev_icons_limit = 2000

    g.fzf_preview_git_status_preview_command =
        [==[[[ $(git diff --cached -- {-1}) != \"\" ]] && git diff --cached --color=always -- {-1} | delta || ]==] ..
        [==[[[ $(git diff -- {-1}) != \"\" ]] && git diff --color=always -- {-1} | delta ]==]

    -- g.fzf_preview_fzf_preview_window_option = 'nohidden'
    g.fzf_preview_default_fzf_options = {
        ["--no-separator"] = true,
        ["--reverse"] = true,
        ["--history"] = "/dev/null",
        ["--preview-window"] = "wrap",
    }

    cmd.packadd("fzf")
    cmd.packadd("fzf.vim")

    -- Hide status and ruler for fzf
    -- api.nvim_create_autocmd(
    --     "User",
    --     {
    --         pattern = "FzfStatusLine",
    --         callback = function()
    --             -- Lualine picks this up and does a nice statusline
    --             -- require("plugs.fzf").fzf_statusline()
    --         end
    --     }
    -- )

    -- Colors
    command(
        "Colorschemes",
        function(a)
            fn["fzf#vim#colors"](g.fzf_vim_opts, a.bang)
        end,
        {bang = true}
    )

    -- Buffers
    -- command(
    --     "Buffers",
    --     function(a)
    --         local preview = fn["fzf#vim#with_preview"](g.fzf_vim_opts, "right:60%:default")
    --         fn["fzf#vim#buffers"](preview, a.bang)
    --     end,
    --     {bang = true}
    -- )

    -- Files
    command(
        "Files",
        function(a)
            local preview = fn["fzf#vim#with_preview"](g.fzf_vim_opts, "right:60%:default")
            fn["fzf#vim#files"](a.args, preview, a.bang)
        end,
        {nargs = "?", complete = "dir", bang = true}
    )

    -- Conf
    -- command(
    --     "Conf",
    --     function(a)
    --         local preview = fn["fzf#vim#with_preview"](g.fzf_vim_opts, "right:60%:default")
    --         fn["fzf#vim#files"]("~/.config", preview, a.bang)
    --     end,
    --     {nargs = "?", complete = "dir", bang = true}
    -- )

    -- Proj
    -- cmd[[
    --     command! -bang Proj
    --         \ call fzf#vim#files('~/projects', fzf#vim#with_preview(), <bang>0)
    -- ]]

    -- Dots
    -- cmd[[
    --     command! Dots call fzf#run(fzf#wrap({
    --     \ 'source': 'dotbare ls-files --full-name --directory "${DOTBARE_TREE}" '
    --         \ . '| awk -v home="${DOTBARE_TREE}/" "{print home \$0}"',
    --     \ 'sink': 'e',
    --     \ 'options': [ '--multi', '--preview', 'cat {}' ]
    --     \ }))
    -- ]]

    -- Apropos
    cmd[[
        command! -nargs=? Apropos call fzf#run(fzf#wrap({
            \ 'source': 'apropos '
                \ . (len(<q-args>) > 0 ? shellescape(<q-args>) : ".")
                \ .' | cut -d " " -f 1',
            \ 'sink': 'tab Man',
            \ 'options': [
                \ '--preview', 'MANPAGER=cat MANWIDTH='.(&columns/2-4).' man {}']}))
    ]]

    -- RipgrepFzf
    cmd[[
        command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

        function! RipgrepFzf(query, fullscreen)
            let command_fmt = 'rg --column --line-number --no-heading '
                \ . '--color=always --smart-case -- %s || true'
            let initial_command = printf(command_fmt, shellescape(a:query))
            let reload_command = printf(command_fmt, '{q}')
            let spec = {'options':
                \ ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
            call fzf#vim#grep(initial_command, 1,
                \ fzf#vim#with_preview(spec, 'right:60%:default'), a:fullscreen)
        endfunction
    ]]

    -- Word completion popup
    -- cmd [[
    -- inoremap <expr> <C-x><C-w> fzf#vim#complete#word({
    --   \ 'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})
    -- ]]

    -- Word completion window
    -- cmd [[
    -- inoremap <expr> <C-x><C-a> fzf#vim#complete({
    --   \ 'source':  'cat /usr/share/dict/words',
    --   \ 'options': '--multi --reverse --margin 15%,0',
    --   \ 'left':    20})
    -- ]]

    -- Clipboard manager
    --   cmd [[
    --   inoremap <expr> <a-.> fzf#vim#complete({
    --     \ 'source': 'copyq eval -- "tab(\"&clipboard\"); for(i=size(); i>0; --i) print(str(read(i-1)) + \"\n\");" \| tac',
    --     \ 'options': '--no-border',
    --     \ 'reducer': { line -> substitute(line[0], '^ *[0-9]\+ ', '', '') },
    --     \ 'window': 'call FloatingFZF()'})
    -- ]]

    --   cmd [[
    --   inoremap <expr> <a-.> fzf#complete({
    --       \ 'source': 'greenclip print 2>/dev/null \| grep -v "^\s*$" \| nl -w2 -s" "',
    --       \ 'options': '--no-border',
    --       \ 'reducer': { line -> substitute(line[0], '^ *[0-9]\+ ', '', '') },
    --       \ 'window': 'call FloatingFZF()'})
    -- ]]

    map(
        "i",
        "<A-.>",
        function()
            fn["fzf#complete"]({
                source = [[greenclip print 2>/dev/null | grep -v "^\s*$" | nl -w2 -s" "]],
                options = {"--no-border"},
                reducer = function(line)
                    local mod = line[1]:gsub("^%s*[0-9]+%s", "")
                    mod = mod:gsub(" ", "\n") -- Replace non-breakable space
                    return mod
                end,
                window = "call FloatingFZF()",
            })
        end,
        {expr = true}
    )

    -- Floating window
    cmd[[
    function! s:create_float(hl, opts)
      let buf = nvim_create_buf(v:false, v:true)
      let opts = extend({'relative': 'editor', 'style': 'minimal'}, a:opts)
      let win = nvim_open_win(buf, v:true, opts)
      call setwinvar(win, '&winhighlight', 'NormalFloat:'.a:hl)
      call setwinvar(win, '&colorcolumn', '')
      return buf
    endfunction

    function! FloatingFZF()
      " Size and position
      let width = float2nr(&columns * 0.9)
      let height = float2nr(&lines * 0.6)
      let row = float2nr((&lines - height) / 2)
      let col = float2nr((&columns - width) / 2)

      " Border
      let top = '╭─' . repeat('─', width - 4) . '─╮'
      let mid = '│'  . repeat(' ', width - 2) .  '│'
      let bot = '╰─' . repeat('─', width - 4) . '─╯'
      let border = [top] + repeat([mid], height - 2) + [bot]

      " Draw frame
      let s:frame = s:create_float('FloatBorder',
        \ {'row': row, 'col': col, 'width': width, 'height': height})
      call nvim_buf_set_lines(s:frame, 0, -1, v:true, border)

      " Draw viewport
      call s:create_float('Normal',
        \ {'row': row + 1, 'col': col + 2, 'width': width - 4, 'height': height - 2})

      augroup fzf_floating
        au!
        au BufWipeout <buffer> execute 'bwipeout' s:frame
      augroup END
    endfunction
  ]]

    -- Fzf wrapper
    cmd[[
        function! FzfWrapper(opts) abort
            let opts = a:opts
            let options = ''
            if has_key(opts, 'options')
                let options = type(opts.options) == v:t_list ? join(opts.options) : opts.options
            endif
            if options !~ '--expect' && has_key(opts, 'sink*')
                let Sink = remove(opts, 'sink*')
                let wrapped = fzf#wrap(opts)
                let wrapped['sink*'] = Sink
            else
                let wrapped = fzf#wrap(opts)
            endif
            call fzf#run(wrapped)
        endfunction

        sil! au! fzf_buffers *
        sil! aug! fzf_buffers
    ]]

    nvim.autocmd.lmb__Fzf = {
        {
            event = "FileType",
            pattern = "fzf",
            command = function(args)
                local buf = args.buf
                require("plugs.fzf").prepare_ft()
                map("t", "<Esc>", "<C-c>", {buffer = buf, desc = "Use escape with FZF"})
                Rc.api.del_keymap("t", "<C-c>", {buffer = buf})
            end,
        },
        {
            event = "VimResized",
            pattern = "*",
            command = function()
                pcall(M.resize_preview_layout)
            end,
        },
        {
            -- Lazy loads fzf
            event = "FuncUndefined",
            pattern = "fzf#*",
            command = function()
                require("plugs.fzf")
            end,
        },
        {
            event = "CmdUndefined",
            pattern = {"FZF", "BCommits", "History", "GFiles", "Marks", "Buffers", "Rg"},
            command = function()
                require("plugs.fzf")
            end,
        },
    }

    command(
        "Helptags",
        [[call fzf#vim#helptags(<bang>0)]],
        {bang = true, bar = true, desc = "Help pages"}
    )
    command(
        "Maps",
        [[call fzf#vim#maps(<q-args>, <bang>0)]],
        {nargs = "*", bang = true, bar = true, desc = "Mappings"}
    )

    wk.register({
        -- ["<Leader>fc"] = {
        --     [[:lua require('usr.shared.utils.git').root_exe('BCommits')<CR>]],
        --     "BCommits Git (fzf)",
        -- },
        -- ["<Leader>fg"] = {
        --     [[:lua require('usr.shared.utils.git').root_exe('GFiles')<CR>]],
        --     "GFiles Git (fzf)",
        -- },
        ["<Leader>fz"] = {
            [[:lua require('usr.shared.utils.git').root_exe(require('plugs.fzf').files)<CR>]],
            "Files Git (fzf)",
        },
        ["<Leader>f,"] = {[[<Cmd>lua require('usr.shared.utils.git').root_exe('Rg')<CR>]],
            "Rg Git (fzf)"},
        ["<Leader>lo"] = {"<Cmd>Locate .<CR>", "Locate (fzf)"},
        -- ["<C-f>"] = {":Rg<CR>", "Builtin Rg (fzf)"},
        -- ["<Leader>A"] = {":Windows<CR>", "Windows (fzf)"},
        -- ["<LocalLeader>r"] = {":RG<CR>", "RG (fzf)"},
        -- ["<A-f>"] = {":Files<CR>", "Files (fzf)"},
        -- ["<LocalLeader>hf"] = {":History<CR>", "File history (fzf)"},
        ["<LocalLeader>hc"] = {":History:<CR>", "Command history (fzf)"},
        ["q:"] = {":History:<CR>", "Command history (fzf)"},
    })

    map("n", "<Leader>cm", "<Cmd>Commands<CR>", {desc = "Commands (fzf)"})
    -- map("n", "<Leader>gf", "<Cmd>GFiles<CR>", { silent = true })
    -- map("n", "<Leader>ht", "<Cmd>Helptags<CR>", { silent = true })

    -- Tags
    -- map("n", "<Leader>t", ":Tags<CR>", {silent = true})
    -- map("n", "<A-t>", ":BTags<CR>", {silent = true})

    map("i", "<C-x><C-l>", "<Plug>(fzf-complete-line)")

    map("n", "<C-,>m", "<Plug>(fzf-maps-n)")
    map("x", "<C-,>m", "<Plug>(fzf-maps-x)")
    map("i", "<C-,>m", "<Plug>(fzf-maps-i)")
    map("o", "<C-,>m", "<Plug>(fzf-maps-o)")

    map(
        "n",
        "<Leader>fe",
        function()
            vim.ui.input(
                {prompt = "Search: "},
                function(term)
                    if term then
                        vim.schedule(function()
                            local preview = fn["fzf#vim#with_preview"]()
                            fn["fzf#vim#locate"](term, preview)
                        end)
                    end
                end
            )
        end,
        {silent = true, desc = "Locate query (fzf)"}
    )

    M.resize_preview_layout()
end

init()

return M
