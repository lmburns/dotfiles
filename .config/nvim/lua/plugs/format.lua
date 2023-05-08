local M = {}

-- local D = require("dev")
local coc = require("plugs.coc")
local gittool = require("common.gittool")
local utils = require("common.utils")
local mpi = require("common.api")
local map = mpi.map
local augroup = mpi.augroup
local W = require("common.api.win")

-- local promise = require("promise")
local async = require("async")

local cmd = vim.cmd
local g = vim.g
local api = vim.api
local fn = vim.fn
local F = vim.F

local scan = require("plenary.scandir")

-- local prefer_neoformat
local prefer_coc

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
---@param save boolean Should file be saved
function M.neoformat(save)
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
                    respect_gitignore = false,
                }
            ),
            {}
        ) > 0
    then
        cmd("lockmarks keepjumps Neoformat stylua")
    else
        cmd("lockmarks keepjumps Neoformat")
    end

    if save then
        save_doc(0)
    end
end

---@return string
function M.promisify()
    -- api.nvim_command_output("messages"),
    return unpack(mpi.get_vim_output("lua require('plugs.format').neoformat()"))
end

---Format the document using `Neoformat`
---@param save boolean whether to save the document
function M.format_doc(save)
    save = F.unwrap_or(save, true)
    local view = W.win_save_positions(0)
    local bufnr = api.nvim_get_current_buf()

    gittool.root_exe(
        function()
            if coc.did_init() then
                if not _t(prefer_coc):contains(vim.bo[bufnr].ft) then
                    M.neoformat(save)
                    return
                end

                async(
                    function()
                        local hasfmt = await(coc.action("hasProvider", {"format"}))
                        if hasfmt then
                            local res = await(coc.action("format"))
                            if res == false then
                                nvim.echo({{"Coc failed to format buffer", "ErrorMsg"}})
                                -- nvim.echo({{"Coc formatted buffer", "WarningMsg"}})
                            end
                        else
                            -- local output = M.promisify()
                            -- nvim.echo(
                            --     {
                            --         {"Coc doesn't support format", "ErrorMsg"},
                            --         {("\n%s"):format(output), "TSNote"}
                            --     }
                            -- )
                            api.nvim_buf_call(
                                bufnr,
                                function()
                                    M.neoformat(save)
                                end
                            )
                        end
                    end
                )
            else
                -- M.neoformat(save)
            end
        end
    )

    if save then
        save_doc(bufnr)
    end

    view.restore()
end

---Format selected text
---@param mode boolean
---@param save boolean whether to save file
function M.format_selected(mode, save)
    if not coc.did_init() then
        return
    end

    save = F.unwrap_or(save, true)
    local view = W.win_save_positions(0)
    local bufnr = api.nvim_get_current_buf()

    gittool.root_exe(
        function()
            async(function()
                local hasfmt = await(coc.action(
                    "hasProvider",
                    {F.if_expr(mode, "formatRange", "format")}
                ))
                -- TODO: make sure this actually returns an error string
                if hasfmt then
                    local _, err = await(coc.action(
                        F.if_expr(mode, "formatSelected", "format"),
                        {mode}
                    ))
                    if err then
                        nvim.echo({{"Coc failed to format: ", "WarningMsg"}, {err, "ErrorMsg"}})
                    end
                end
            end)
        end
    )

    if save then
        save_doc(bufnr)
    end

    view.restore()
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
        surround_whereop_typeparameters = true,
    }

    augroup(
        "lmb__FormattingJulia",
        {
            event = "FileType",
            pattern = "julia",
            command = function()
                map("n", ";ff", "<Cmd>JuliaFormatterFormat<CR>", {buffer = true})
                map("x", ";ff", "<Cmd>JuliaFormatterFormat<CR>", {buffer = true})
            end,
        }
    )
end

-- TODO: Get keepj keepp to prevent neoformat from modifying changes
--       g; moves to last line after format
local function init()
    M.juliaformat()
    -- prefer_neoformat = {"json", "typescriptreact", "typescript", "javascript"}
    prefer_coc = {"lua", "json", "typescriptreact", "typescript", "javascript"}

    g.neoformat_basic_format_retab = 1
    g.neoformat_basic_format_trim = 1
    g.neoformat_basic_format_align = 1

    g.neoformat_enabled_python = {"black"}
    g.neoformat_enabled_zsh = {"expand"}
    g.neoformat_enabled_java = {"prettier"}
    g.neoformat_enabled_graphql = {"prettier"}
    g.neoformat_enabled_solidity = {"prettier"}
    g.neoformat_enabled_javascript = {"prettier"}
    -- g.neoformat_enabled_typescript = {"prettier", "clangformat"}
    -- g.neoformat_enabled_typescriptreact = {"prettier", "clangfmt"}
    g.neoformat_enabled_typescript = {"prettier", "clangfmt"}
    g.neoformat_typescript_clangfmt = {
        exe = "clang-format",
        stdin = 1,
        try_node_exe = 0,
    }
    g.neoformat_enabled_typescriptreact = {"prettier", "clangfmt"}
    -- g.neoformat_typescriptreact_clangfmt = {
    --     exe = "clang-format",
    --     args = {"--assume-filename", ".ts"},
    --     stdin = 1,
    --     no_append = true
    -- }
    g.neoformat_typescriptreact_clangfmt = {
        exe = "cat",
        args = {'"%:p"', "|", "clang-format", "--assume-filename", ".ts"},
        stdin = 1,
        no_append = true,
        try_node_exe = 0,
    }
    g.neoformat_enabled_yaml = {"prettier"}
    g.neoformat_yaml_prettier = {
        exe = "prettier",
        args = {"--stdin-filepath", '"%:p"', "--tab-width=2"},
        stdin = 1,
    }
    g.neoformat_enabled_ruby = {"rubocop"}
    g.neoformat_ruby_rubocop = {
        exe = "rubocop",
        args = {
            "--auto-correct",
            "--stdin",
            '"%:p"',
            "2>/dev/null",
            "|",
            'sed "1,/^====================$/d"'
        },
        stdin = 1,
        stderr = 1,
    }
    g.neoformat_enabled_sql = {"sqlformatter"}
    g.neoformat_sql_sqlformatter = {
        exe = "sql-formatter",
        args = {"--indent", "4"},
        stdin = 1,
    }
    g.neoformat_enabled_json = {"prettier", "jq"}
    g.neoformat_json_jq = {exe = "jq", args = {"--indent", "4"}, stdin = 1}

    g.neoformat_enabled_lua = {"luafmtext", "luaformat", "stylua"}
    g.neoformat_lua_luafmtext = {
        exe = "lua-fmt-ext",
        args = {"--stdin", "--line-width", "100"},
        stdin = 1,
    }

    map(
        "n",
        ";ff",
        [[<Cmd>lua require('plugs.format').format_doc()<CR>]],
        {silent = true, desc = "Format document"}
    )
    map(
        "x",
        ";ff",
        [[:lua require('plugs.format').format_selected(vim.fn.visualmode())<CR>]],
        {silent = true, desc = "Format selected"}
    )

    map(
        "n",
        ";fn",
        [[<Cmd>lua require('plugs.format').neoformat()<CR>]],
        {silent = true, desc = "NeoFormat document"}
    )
    map(
        "n",
        ";fm",
        [[<Cmd>Format<CR>]],
        {silent = true, desc = "CocFormat document"}
    )

    augroup(
        "lmb__Formatting",
        {
            event = "FileType",
            pattern = "crystal",
            command = function(args)
                map(
                    "n",
                    ";ff",
                    "<Cmd>CrystalFormat<CR>",
                    {buffer = args.buf, silent = true, desc = "Format document"}
                )
            end,
        },
        {
            event = "FileType",
            pattern = "vim",
            command = function(args)
                map(
                    "n",
                    ";ff",
                    "=ie",
                    {buffer = args.buf, noremap = false, desc = "Format document"}
                )
                map("x", ";ff", "=", {buffer = args.buf, desc = "Format selected"})
            end,
        }
    )
end

init()

return M
