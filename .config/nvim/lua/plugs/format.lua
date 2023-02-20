local M = {}

-- FIX: The coc formatter provided doesn't read configs

local D = require("dev")
local coc = require("plugs.coc")
local log = require("common.log")
local gittool = require("common.gittool")
local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup

-- local promise = require("promise")
-- local async = require("async")
-- local a = require("plenary.async_lib")

local cmd = vim.cmd
local g = vim.g
local api = vim.api
local fn = vim.fn
local F = vim.F

-- local Path = require("plenary.path")
local scan = require("plenary.scandir")

local prefer_neoformat

local function save_doc(bufnr)
    vim.schedule(
        function()
            api.nvim_buf_call(
                bufnr,
                function()
                    cmd("sil! up")
                end
            )
        end
    )
end

---Run `Neoformat` on the buffer
function M.neoformat()
    local bufnr = api.nvim_get_current_buf()
    -- This is a little dense
    if
        vim.bo[bufnr].ft == "lua" and
            #F.if_nil(
                scan.scan_dir(
                    gittool.root() or fn.expand("%:p:h"),
                    {
                        search_pattern = "%.?stylua.toml$",
                        hidden = true,
                        silent = true,
                        respect_gitignore = false
                    }
                ),
                {}
            ) > 0
     then
        cmd.Neoformat("stylua")
    else
        cmd.Neoformat()
    end

    -- cmd("sil! up")
end

---@return string
function M.promisify()
    -- api.nvim_command_output("messages"),
    return unpack(D.get_vim_output("lua require('plugs.format').neoformat()"))
end

---Format the document using `Neoformat`
---@param save boolean whether to save the document
function M.format_doc(save)
    save = utils.get_default(save, true)
    local view = utils.save_win_positions(0)

    gittool.root_exe(
        function()
            if coc.did_init() then
                local bufnr = api.nvim_get_current_buf()

                -- if _t({"typescript", "javascript"}):contains(vim.bo[bufnr].ft) then
                --     neoformat()
                --     return
                -- end

                -- FIX: This somehow brings up HLSLens
                local err, res = coc.a2sync("hasProvider", {"format"}, 2000)

                if not err and res == true then
                    fn.CocActionAsync(
                        "format",
                        "",
                        function(e, res)
                            -- Now, result has to be checked as false here
                            if e ~= vim.NIL or _t(prefer_neoformat):contains(vim.bo[bufnr].ft) or res == false then
                                api.nvim_buf_call(
                                    bufnr,
                                    function()
                                        -- local output = M.promisify()
                                        -- nvim.echo(
                                        --     {
                                        --         {"Coc unsuccessfully formatted buffer", "ErrorMsg"},
                                        --         {("\n%s"):format(output), "WarningMsg"}
                                        --     }
                                        -- )
                                        M.neoformat()
                                    end
                                )
                            else
                                if save then
                                    save_doc(bufnr)
                                end
                            end
                        end
                    )
                else
                    -- local output = M.promisify()
                    -- nvim.echo(
                    --     {
                    --         {"Coc doesn't support format", "ErrorMsg"},
                    --         {("\n%s"):format(output), "TSNote"}
                    --     }
                    -- )
                    M.neoformat()
                end
            else
                M.neoformat()
            end
        end
    )

    view.restore()
end

---Format selected text
---@param mode boolean
---@param save boolean whether to save file
function M.format_selected(mode, save)
    save = save == nil and true or save
    if not coc.did_init() then
        return
    end

    gittool.root_exe(
        function()
            local err, res =
                coc.a2sync(
                "hasProvider",
                {
                    F.tern(mode, "formatRange", "format")
                },
                2000
            )
            if not err and res == true then
                local bufnr = api.nvim_get_current_buf()
                fn.CocActionAsync(
                    mode and "formatSelected" or "format",
                    mode,
                    function(e, _)
                        if e ~= vim.NIL then
                            log.warn(e, true)
                        else
                            -- if vim.bo[bufnr].ft == "lua" then
                            --     M.neoformat()
                            -- end

                            if save then
                                save_doc(bufnr)
                            end
                        end
                    end
                )
            end
        end
    )
end

function M.juliaformat()
    g.JuliaFormatter_options = {
        indent = 4,
        margin = 92,
        always_for_in = false,
        whitespace_typedefs = false,
        whitespace_ops_in_indices = true,
        normalize_line_ends = "unix",
        remove_extra_newlines = true,
        import_to_using = false,
        pipe_to_function_call = false,
        short_to_long_function_def = false,
        long_to_short_function_def = false,
        always_use_return = false, -- implicit return
        whitespace_in_kwargs = false,
        annotate_untyped_fields_with_any = true,
        format_docstrings = true,
        conditional_to_if = false, -- ternary to conditional
        trailing_comma = true,
        indent_submodule = true,
        separate_kwargs_with_semicolon = false,
        surround_whereop_typeparameters = true
    }

    augroup(
        "lmb__FormattingJulia",
        {
            event = "FileType",
            pattern = "julia",
            command = function()
                map("n", ";ff", "<Cmd>JuliaFormatterFormat<CR>", {buffer = true})
                map("x", ";ff", "<Cmd>JuliaFormatterFormat<CR>", {buffer = true})
            end
        }
    )
end

-- TODO: Get keepj keepp to prevent neoformat from modifying changes
--       g; moves to last line after format
local function init()
    M.juliaformat()
    prefer_neoformat = {"lua", "json"}

    g.neoformat_basic_format_retab = 1
    g.neoformat_basic_format_trim = 1
    g.neoformat_basic_format_align = 1

    g.neoformat_enabled_python = {"black"}
    g.neoformat_enabled_zsh = {"expand"}
    g.neoformat_enabled_java = {"prettier"}
    g.neoformat_enabled_graphql = {"prettier"}
    g.neoformat_enabled_solidity = {"prettier"}
    g.neoformat_enabled_typescript = {"prettier", "clangformat"}
    g.neoformat_enabled_javascript = {"prettier"}
    g.neoformat_enabled_yaml = {"prettier"}
    g.neoformat_yaml_prettier = {
        exe = "prettier",
        args = {"--stdin-filepath", '"%:p"', "--tab-width=2"},
        stdin = 1
    }
    g.neoformat_enabled_ruby = {"rubocop"}
    g.neoformat_ruby_rubocop = {
        exe = "rubocop",
        args = {"--auto-correct", "--stdin", '"%:p"', "2>/dev/null", "|", 'sed "1,/^====================$/d"'},
        stdin = 1,
        stderr = 1
    }
    g.neoformat_enabled_sql = {"sqlformatter"}
    g.neoformat_sql_sqlformatter = {
        exe = "sql-formatter",
        args = {"--indent", "4"},
        stdin = 1
    }
    g.neoformat_enabled_json = {"jq"}
    g.neoformat_json_jq = {
        exe = "jq",
        args = {"--indent", "4", "--tab"},
        stdin = 1
    }

    g.neoformat_enabled_lua = {"luafmtext", "stylua", "luaformat"}
    g.neoformat_lua_luafmtext = {
        exe = "lua-fmt-ext",
        args = {"--stdin"},
        stdin = 1
    }

    map("n", ";ff", [[:lua require('plugs.format').format_doc()<CR>]])
    map("x", ";ff", [[:lua require('plugs.format').format_selected(vim.fn.visualmode())<CR>]])

    augroup(
        "lmb__Formatting",
        {
            event = "FileType",
            pattern = "crystal",
            command = function()
                map("n", ";ff", "<Cmd>CrystalFormat<CR>", {buffer = true})
            end
        }
    )
end

init()

return M
