---@module 'plugs.filetype'
local M = {}

local ftplugin = require("usr.lib.ftplugin")

local api = vim.api
local cmd = vim.cmd
local env = vim.env
local fn = vim.fn
local g = vim.g
local detect = require("vim.filetype.detect")

local function nroff_ft(_path, bufnr)
    local winid = fn.bufwinid(bufnr)
    vim.bo[bufnr].filetype = "nroff"
    vim.bo[bufnr].textwidth = 85
    vim.wo[winid].wrap = true
    vim.wo[winid].colorcolumn = "+1"
end

-- require('plenary.filetype').detect_from_extension(fn.expand('%:p'))
-- require('plenary.filetype').detect_from_name(fn.expand('%:p'))
-- require('plenary.filetype').detect_from_modeline(fn.expand('%:p'))
-- require('plenary.filetype').detect_from_shebang(fn.expand('%:p'))

function M.setup()
    vim.filetype.add({
        extension = {
            lock = "yaml",
            gitignore = "gitignore",
            gitconfig = "gitconfig",
            tmTheme = "xml",
            task = "taskedit",
            eslintrc = "json",
            prettierrc = "json",
            pn = "potion",
            -- conf = "conf",
            jq = "jq",
            mdx = "markdown",
            -- md = "markdown",
            mjml = "html",
            moon = "moon",
            sxhkdrc = "sxhkdrc",
            ztst = "ztst",
            csh = "tcsh",
            tcsh = function(path, bufnr)
                return detect.shell(path, vim.filetype.getlines(bufnr), "tcsh")
            end,
            ksh = function(_path, bufnr)
                -- local func = function()
                vim.b[bufnr].is_kornshell = 1
                vim.b[bufnr].is_bash = nil
                vim.b[bufnr].is_sh = nil
                -- end
                api.nvim_buf_call(bufnr, function()
                    vim.defer_fn(function()
                        cmd.syntax("on")
                        cmd.TSBufDisable("highlight")
                    end, 300)
                end)
                -- return detect.shell(path, vim.filetype.getlines(bufnr), "sh"), func
            end,
            rasi = "rasi",
            cr = "crystal",
            ["pre-commit"] = "sh",
            [".editorconfig"] = "ini",
            log = "log",
            ms = nroff_ft,
            me = nroff_ft,
            mom = nroff_ft,
            man = nroff_ft,
            -- -- Set the filetype of files with a dash shebang to sh
            -- dash = "sh",
            -- node = "typescript"
            cpp = function(_path, bufnr)
                vim.bo[bufnr].filetype = "cpp"
                vim.bo[bufnr].cinoptions = vim.bo[bufnr].cinoptions .. "L0"
            end,
            pdf = function(_path, bufnr)
                vim.bo[bufnr].filetype = "pdf"
                vim.defer_fn(function()
                    fn.jobstart("zathura " .. '"' .. fn.expand("%") .. '"')
                end, 300)
            end,
            h = function(_path, bufnr)
                vim.bo[bufnr].filetype = "c"
                g.c_syntax_for_h = 1
            end,
            json = function(_path, bufnr)
                vim.bo[bufnr].shiftwidth = 2
            end,
        },
        filename = {
            ["tsconfig.json"] = "jsonc",
            ["yup.lock"] = "yaml",
            ["yarn.lock"] = "yaml",
            ["poetry.lock"] = "toml",
            ["coc-settings.json"] = "jsonc",
            ["Brewfile"] = "ruby",
            latexmkrc = "perl",
            [".latexmkrc"] = "perl",
            [".gitignore"] = "gitignore",
            [".eslintignore"] = "gitignore",
            [".ignore"] = "gitignore",
            [".fdignore"] = "gitignore",
            [".rgignore"] = "gitignore",
            [".npmignore"] = "gitignore",
            [".clang-format"] = "yaml",
            [".lua-format"] = "yaml",
            ["fonts.conf"] = "xml",
            -- PKGBUILD = "PKGBUILD",
        },
        pattern = {
            -- [".*&zwj;/etc/foo/.*%.conf"] = {"dosini", {priority = 10}},
            [".*/completions/_.*"] = "zsh",
            ["*/xorg.conf.d/*.conf"] = "xf86conf",
            [".*/git/config"] = "gitconfig",
            [".*/fontconfig/conf%.d/.*"] = "xml",
            [".*/fd/ignore"] = "gitignore",
            ["calcurse-note.*"] = "markdown",
            ["~/.local/share/calcurse/notes/.*"] = "markdown",
            [("%s/calcurse/notes/.*"):format(env.XDG_DATA_HOME)] = "markdown",
            [".*sxhkdrc"] = "sxhkdrc",
            ["/tmp/buku%-edit.*"] = "conf",
            ["/tmp/neomutt.*"] = "mail",
            ["README.(%a+)$"] = function(_path, _bufnr, ext)
                if ext == "md" then
                    -- return "vimwiki"
                    return "markdown"
                elseif ext == "rst" then
                    return "markdown"
                end
            end,
            -- [".*"] = {
            --     priority = -math.huge,
            --     function(_path, bufnr)
            --         local content = vim.filetype.getlines(bufnr, 1)
            --         if vim.filetype.matchregex(content, [[^#!.*zsh]]) then
            --             return "zsh"
            --         elseif vim.filetype.matchregex(content, [[\<drawing\>]]) then
            --             return "drawing"
            --         end
            --     end
            -- }
        },
    })
end

function M.setup_ftplugin()
    ftplugin.extend_all({
        vim = {
            opt = {
                commentstring = [[" %s]],
            },
        },
        lfrc = {
            opt = {
                comments = [[:#]],
                commentstring = [[# %s]],
            },
        },
        zsh = {
            opt = {
                comments = [[:#]],
                commentstring = [[# %s]],
            },
        },
        tmux = {
            opt = {
                comments = [[:#]],
                commentstring = [[# %s]],
            },
        },
    })
end

local function init()
    M.setup()
    M.setup_ftplugin()
end

init()

return M