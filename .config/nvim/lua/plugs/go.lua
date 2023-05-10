---@module 'plugs.go'
local M = {}

local D = require("dev")
local mpi = require("common.api")
local augroup = mpi.augroup
local command = mpi.command

local fn = vim.fn
local api = vim.api
local g = vim.g
local cmd = vim.cmd

function M.build_go_files()
    local file = fn.expand("%")
    local test_re = vim.regex([[^\f\+_test\.go$]])
    local build_re = vim.regex([[^\f\+\.go$]])
    if test_re:match_str(file) then
        fn["go#test#Test"](0, 1)
    elseif build_re:match_str(file) then
        fn["go#cmd#Build"](0)
    end
end

function M.setup()
    g.go_rename_command = "gopls"
    g.go_doc_keywordprg_enabled = 1
    g.go_fmt_command = "goimports"
    g.go_list_type = "quickfix"
    g.go_highlight_types = 1
    g.go_highlight_fields = 1
    g.go_highlight_functions = 1
    g.go_highlight_methods = 1
    g.go_highlight_operators = 1
    g.go_highlight_build_constraints = 1
    g.go_highlight_generate_tags = 1
    g.go_gocode_propose_builtins = 1
    g.go_gocode_unimported_packages = 1
    g.go_doc_keywordprg_enabled = 0
    g.go_fmt_fail_silently = 1
    -- g.go_doc_popup_window = 1
    -- g.go_auto_type_info = 1
    -- g.go_updatetime = 100
    -- g.go_auto_sameids = 1
    -- g.go_play_open_browser = 1
end

---@diagnostic disable-next-line:unused-function, unused-local
local function wrap_qf(fname, ...)
    local args = D.tbl_pack(...)
    return function()
        if type(fname) == "string" then
            fn[fname](D.tbl_unpack(args))
        end
        if #fn.getqflist() > 0 then
            cmd.copen()
        end
    end
end

local function init()
    M.setup()

    cmd [[
      function! s:run_go(...)
        if filereadable(expand("%:r"))
          call delete(expand("%:r"))
        endif
        write
        let arg = get(a:, 1, 0)
        if arg == "split"
          execute 'FloatermNew --autoclose=0 --wintype=vsplit --width=0.5 '
            \ . ' go build ./% && ./%:r'
        elseif arg == "float"
          execute 'FloatermNew --autoclose=0 go build ./% && ./%:r'
        endif
      endfunction

      command! GORUNS :call s:run_go("split")
      command! GORUN :call s:run_go("float")
  ]]

    augroup(
        "GoEnv",
        {
            event = "FileType",
            pattern = "go",
            command = function(args)
                local bufnr = args.buf
                vim.opt_local.list = false

                local bmap = function(...)
                    mpi.bmap(bufnr, ...)
                end

                bmap("n", "<Leader>rp", ":GORUNS<CR>")
                bmap("n", "<Leader>ru", ":GORUN<CR>")

                bmap("n", "M", "<Plug>(go-doc)")
                bmap("n", "<Leader>b<CR>", ":lua require('plugs.go').build_go_files()<CR>")
                bmap("n", "<Leader>r<CR>", "<Plug>(go-run)")
                bmap("n", "<Leader>rr", ":GoRun %<CR>")
                bmap("n", "<Leader>ri", ":GoRun %<space>")
                bmap("n", "<Leader>t<CR>", "<Plug>(go-test)")
                bmap("n", "<Leader>c<CR>", "<Plug>(go-coverage-toggle)")
                bmap("n", "<Leader>gae", "<Plug>(go-alternate-edit)")
                bmap("n", "<Leader>i", "<Plug>(go-info)")
                bmap("n", "<Leader>sm", ":GoSameIdsToggle<CR>")

                -- bmap("n", "gd", ":GoDef<CR>")
                -- bmap("n", "gy", ":GoDefType<CR>")
                -- bmap("n", "gi", ":GoImplements<CR>")
                -- bmap("n", "gC", ":GoCallees<CR>")
                -- bmap("n", "gc", ":GoCallers<CR>")
                -- bmap("n", "gr", ":GoReferrers<CR>")

                -- bmap("n", "gd", wrap_qf("go#def#Jump", "", 0)) -- "<Plug>(go-def)"
                -- bmap("n", "gy", wrap_qf("go#def#Jump", "", 1)) -- "<Plug>(go-def-type)"
                -- bmap("n", "gi", wrap_qf("go#implements#Implements", -1)) -- "<Plug>(go-implements)"
                -- bmap("n", "gC", wrap_qf("go#guru#Callees", -1)) -- "<Plug>(go-callees)"
                -- bmap("n", "gc", wrap_qf("go#calls#Callers")) -- "<Plug>(go-callers)"
                -- bmap("n", "gr", wrap_qf("go#referrers#Referrers", -1)) -- "<Plug>(go-referrers)"
                -- bmap("n", "gS", wrap_qf("go#guru#Callstack", -1)) -- "<Plug>(go-callstack)"

                bmap("n", "gd", "<Plug>(go-def)")
                bmap("n", "gy", "<Plug>(go-def-type)")
                bmap("n", "gi", "<Plug>(go-implements)")
                bmap("n", "gK", "<Plug>(go-callees)")
                bmap("n", "gk", "<Plug>(go-callers)")
                bmap("n", "gr", "<Plug>(go-referrers)")
                bmap("n", "gS", "<Plug>(go-callstack)")

                bmap("n", "<Leader>rn", "<Plug>(go-rename)")
                bmap("n", "<Leader>jg", "<Plug>(go-diagnostics)")
                bmap("n", "<Leader>if", "<Plug>(go-iferr)")

                bmap("n", "<Leader>fd", ":GoDeclsDir<CR>")
                bmap("n", "<Leader>fj", ":GoDecls<CR>")

                -- bmap("n", ";ff", ":GoFmt<CR>")

                command(
                    "A",
                    [[call go#alternate#Switch(<bang>0, 'edit')]],
                    {bang = true, desc = "Go switch in new tab"}
                )
                command(
                    "AV",
                    [[call go#alternate#Switch(<bang>0, 'vsplit')]],
                    {bang = true, desc = "Go switch vertical"}
                )
                command(
                    "AS",
                    [[call go#alternate#Switch(<bang>0, 'split')]],
                    {bang = true, desc = "Go switch horizontal"}
                )
            end
        }
    )
end

init()

return M
