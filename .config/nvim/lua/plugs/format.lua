---@module 'plugs.format'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local utils = shared.utils
local gittool = utils.git

local coc = require("plugs.coc")
local ftplugin = require("usr.lib.ftplugin")
local mpi = require("usr.api")
local W = mpi.win
local map = mpi.map
local augroup = mpi.augroup

-- local promise = require("promise")
local async = require("async")

local cmd = vim.cmd
local g = vim.g
local api = vim.api
local fn = vim.fn

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
        utils.preserve("lockm Neoformat stylua")
    else
        utils.preserve("lockm Neoformat")
    end

    if save then
        save_doc(0)
    end
end

---@return string
function M.promisify()
    -- api.nvim_command_output("messages"),
    return unpack(mpi.get_ex_output("lua require('plugs.format').neoformat()", true))
end

---Format the document using `Neoformat`
---@param save boolean whether to save the document
function M.format_doc(save)
    save = F.unwrap_or(save, true)
    local view = W.win_save_positions(0)
    local bufnr = api.nvim_get_current_buf()

    gittool.root_exe(function()
        if coc.did_init() then
            if not _t(prefer_coc):contains(vim.bo[bufnr].ft) then
                M.neoformat(save)
                return
            end

            async(function()
                local hasfmt = await(coc.action("hasProvider", {"format"}))
                if hasfmt then
                    local res = await(coc.action("format"))
                    if res == false then
                        nvim.echo({{"Coc failed to format buffer", "ErrorMsg"}})
                        -- nvim.echo({{"Coc formatted buffer", "WarningMsg"}})
                    end
                else
                    -- local output = M.promisify()
                    -- nvim.echo({
                    --     {"Coc doesn't support format", "ErrorMsg"},
                    --     {("\n%s"):format(output), "TSNote"},
                    -- })

                    api.nvim_buf_call(bufnr, function()
                        M.neoformat(save)
                    end)
                end
            end)
        else
            -- M.neoformat(save)
        end
    end)

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

    gittool.root_exe(function()
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
    end)

    if save then
        save_doc(bufnr)
    end

    view.restore()
end

-- TODO: Get keepj keepp to prevent neoformat from modifying changes
--       g; moves to last line after format
local function init()
    prefer_coc = {
        "lua",
        "json",
        "typescriptreact",
        "typescript",
        "javascript",
        "rust",
    }

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
            'sed "1,/^====================$/d"',
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
        F.ithunk(utils.preserve, [[call v:lua.require'plugs.format'.format_doc()]]),
        {desc = "Format document"}
    )
    map(
        "x",
        ";ff",
        [[require('plugs.format').format_selected(vim.fn.visualmode())]],
        {lcmd = true, desc = "Format selected"}
    )
    map(
        "n",
        ";fn",
        F.ithunk(utils.preserve, [[lockm call v:lua.require'plugs.format'.neoformat()]]),
        {desc = "NeoFormat document"}
    )
    map(
        "n",
        ";fm",
        F.ithunk(utils.preserve, "Format"),
        {desc = "CocFormat document"}
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
                    F.ithunk(utils.preserve, "CrystalFormat"),
                    {buffer = args.buf, desc = "Format document"}
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
                    F.ithunk(utils.preserve, "norm =ie"),
                    {buffer = args.buf, desc = "Format document"}
                )
                map(
                    "x",
                    ";ff",
                    "=",
                    {buffer = args.buf, desc = "Format selected"}
                )
            end,
        }
    )
end

init()

return M
