---@module 'plugs.filetype'
local M = {}

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
                vim.b[bufnr].is_kornshell = 1
                vim.b[bufnr].is_bash = nil
                vim.b[bufnr].is_sh = nil
                api.nvim_buf_call(bufnr, function()
                    vim.defer_fn(function()
                        cmd.syntax("on")
                        cmd.TSBufDisable("highlight")
                    end, 300)
                end)
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
            pdf = function(_path, bufnr)
                vim.bo[bufnr].filetype = "pdf"
                vim.defer_fn(function()
                    fn.jobstart(("zathura '%s'"):format(fn.expand("%")))
                end, 300)
            end,
            h = function(_path, bufnr)
                vim.bo[bufnr].filetype = "c"
                g.c_syntax_for_h = 1
            end,
        },
        filename = {
            ["tsconfig.json"] = "jsonc",
            ["yup.lock"] = "yaml",
            ["yarn.lock"] = "yaml",
            ["poetry.lock"] = "toml",
            ["coc-settings.json"] = "jsonc",
            Brewfile = "ruby",
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
            sxhkdrc = "sxhkdrc",
            -- PKGBUILD = "PKGBUILD",
        },
        pattern = {
            -- [".*&zwj;/etc/foo/.*%.conf"] = {"dosini", {priority = 10}},
            [".*/completions/_.*"] = "zsh",
            [".*/xorg%.conf%.d/*.conf"] = "xf86conf",
            [".*/git/config"] = "gitconfig",
            [".*/fontconfig/conf%.d/.*"] = "xml",
            [".*/fd/ignore"] = "gitignore",
            ["/tmp/buku%-edit.*"] = "conf",
            ["/tmp/neomutt.*"] = "mail",
            ["README%.(%a+)$"] = function(_path, _bufnr, ext)
                if ext == "md" then
                    -- return "vimwiki"
                    return "markdown"
                elseif ext == "rst" then
                    return "markdown"
                end
            end,
            ["calcurse-note.*"] = "markdown",
            ["~/.local/share/calcurse/notes/.*"] = "markdown",
            [("%s/calcurse/notes/.*"):format(Rc.dirs.xdg.data)] = "markdown",
            [Rc.dirs.home .. "/Documents/wiki/vimwiki/.*.md"] = "vimwiki",
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
    local ftplugin = require("usr.lib.ftplugin")

    ftplugin.extend_all({
        PKGBUILD = {opt = {comments = [[:#]], commentstring = [[# %s]]}},
        cabalconfig = {opt = {commentstring = [[-- %s]]}},
        dirdiff = {opt = {list = false, buflistlist = false}},
        taskrc = {opt = {comments = [[:#]], commentstring = [[# %s]]}},
        tmux = {opt = {comments = [[:#]], commentstring = [[# %s]]}},
        lf = {opt = {comments = [[:#]], commentstring = [[# %s]]}},
        rasi = {opt = {comments = [[s1:/* ,mb:* ,ex:*/,://]], commentstring = [[// %s]]}},
        yaml = {opt = {shiftwidth = 2}},
        vimwiki = {opt = {comments = [[:%%,s1:<!--,mb: ,ex:-->]], commentstring = [[%% %s]]}},
        markdown = {opt = {comments = [[:%%,s1:<!--,mb: ,ex:-->]], commentstring = [[%% %s]]}},
        vim = {
            opt = {
                -- comments = [[sO:" -,mO:"  ,eO:",:"]],
                commentstring = [[" %s]],
            },
        },
        zsh = {
            opt = {
                comments = [[:#]],
                commentstring = [[# %s]],
                shiftwidth = 2,
            },
        },
        c = {
            opt = {
                textwidth = 80,
                comments = [[sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,:///,://!,://]],
                commentstring = [[// %s]],
            },
        },
        rust = {
            opt = {
                textwidth = 100,
                comments = [[sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,:///,://!,://]],
                commentstring = [[// %s]],
                -- timeoutlen = 500,
            },
            bufvar = {
                coc_disabled_sources = {"word"},
            },
        },
        lua = {
            bufvar = {
                coc_disabled_sources = {"word"},
                -- matchup_matchparen_enabled = 0,
                -- matchup_matchparen_fallback = 0,
            },
        },
        javascript = {
            opt = {
                comments = [[sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,://]],
                commentstring = [[// %s]],
            },
        },
        typescript = {
            opt = {
                comments = [[sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,://]],
                commentstring = [[// %s]],
            },
        },
        jsonc = {
            opt = {
                comments = [[sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,://]],
                commentstring = [[// %s]],
                concealcursor = "c",
                conceallevel = 0,
                shiftwidth = 2,
            },
        },
        json = {
            opt = {
                concealcursor = "c",
                conceallevel = 0,
                shiftwidth = 2,
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
