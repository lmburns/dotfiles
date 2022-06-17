local M = {}

local dev = require("dev")
local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup
local command = utils.command

local g = vim.g

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

local function wrap_qf(fname, ...)
    local args = dev.tbl_pack(...)
    return function()
        if type(fname) == "string" then
            fn[fname](dev.tbl_unpack(args))
        end
        if #fn.getqflist() > 0 then
            ex.copen()
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
            command = function()
                local bufnr = api.nvim_get_current_buf()
                vim.opt_local.list = false

                map(bufnr, "n", "<Leader>rp", ":GORUNS<CR>")
                map(bufnr, "n", "<Leader>ru", ":GORUN<CR>")

                map(bufnr, "n", "M", "<Plug>(go-doc)")
                map(bufnr, "n", "<Leader>b<CR>", ":lua require('plugs.go').build_go_files()<CR>")
                map(bufnr, "n", "<Leader>r<CR>", "<Plug>(go-run)")
                map(bufnr, "n", "<Leader>rr", ":GoRun %<CR>")
                map(bufnr, "n", "<Leader>ri", ":GoRun %<space>")
                map(bufnr, "n", "<Leader>t<CR>", "<Plug>(go-test)")
                map(bufnr, "n", "<Leader>c<CR>", "<Plug>(go-coverage-toggle)")
                map(bufnr, "n", "<Leader>gae", "<Plug>(go-alternate-edit)")
                map(bufnr, "n", "<Leader>i", "<Plug>(go-info)")
                map(bufnr, "n", "<Leader>sm", ":GoSameIdsToggle<CR>")

                -- map(bufnr, "n", "gd", ":GoDef<CR>")
                -- map(bufnr, "n", "gy", ":GoDefType<CR>")
                -- map(bufnr, "n", "gi", ":GoImplements<CR>")
                -- map(bufnr, "n", "gC", ":GoCallees<CR>")
                -- map(bufnr, "n", "gc", ":GoCallers<CR>")
                -- map(bufnr, "n", "gr", ":GoReferrers<CR>")

                -- map(bufnr, "n", "gd", wrap_qf("go#def#Jump", "", 0)) -- "<Plug>(go-def)"
                -- map(bufnr, "n", "gy", wrap_qf("go#def#Jump", "", 1)) -- "<Plug>(go-def-type)"
                -- map(bufnr, "n", "gi", wrap_qf("go#implements#Implements", -1)) -- "<Plug>(go-implements)"
                -- map(bufnr, "n", "gC", wrap_qf("go#guru#Callees", -1)) -- "<Plug>(go-callees)"
                -- map(bufnr, "n", "gc", wrap_qf("go#calls#Callers")) -- "<Plug>(go-callers)"
                -- map(bufnr, "n", "gr", wrap_qf("go#referrers#Referrers", -1)) -- "<Plug>(go-referrers)"
                -- map(bufnr, "n", "gS", wrap_qf("go#guru#Callstack", -1)) -- "<Plug>(go-callstack)"

                map(bufnr, "n", "gd", "<Plug>(go-def)")
                map(bufnr, "n", "gy", "<Plug>(go-def-type)")
                map(bufnr, "n", "gi", "<Plug>(go-implements)")
                map(bufnr, "n", "gK", "<Plug>(go-callees)")
                map(bufnr, "n", "gk", "<Plug>(go-callers)")
                map(bufnr, "n", "gr", "<Plug>(go-referrers)")
                map(bufnr, "n", "gS", "<Plug>(go-callstack)")

                map(bufnr, "n", "<Leader>rn", "<Plug>(go-rename)")
                map(bufnr, "n", "<Leader>jg", "<Plug>(go-diagnostics)")
                map(bufnr, "n", "<Leader>if", "<Plug>(go-iferr)")

                map(bufnr, "n", "<Leader>fd", ":GoDeclsDir<CR>")
                map(bufnr, "n", "<Leader>fj", ":GoDecls<CR>")

                -- map(bufnr, "n", ";ff", ":GoFmt<CR>")

                command("A", [[call go#alternate#Switch(<bang>0, 'edit')]], {bang = true})
                command("AV", [[call go#alternate#Switch(<bang>0, 'vsplit')]], {bang = true})
                command("AS", [[call go#alternate#Switch(<bang>0, 'split')]], {bang = true})
            end
        }
    )
end

init()

return M
