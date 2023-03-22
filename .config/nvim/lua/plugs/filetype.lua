local M = {}

local fn = vim.fn
local g = vim.g
local b = vim.bo
local w = vim.wo
local o = vim.opt

local nroff_ft = function()
    b.filetype = "nroff"
    w.wrap = true
    b.textwidth = 85
    w.colorcolumn = "+1"
end

-- require('plenary.filetype').detect_from_extension(fn.expand('%:p'))
-- require('plenary.filetype').detect_from_name(fn.expand('%:p'))
-- require('plenary.filetype').detect_from_modeline(fn.expand('%:p'))
-- require('plenary.filetype').detect_from_shebang(fn.expand('%:p'))

function M.setup()
    vim.filetype.add(
        {
            extension = {
                lock = "yaml",
                gitignore = "gitignore",
                gitconfig = "gitconfig",
                tmTheme = "xml",
                task = "taskedit",
                eslintrc = "json",
                prettierrc = "json",
                pn = "potion",
                conf = "conf",
                jq = "jq",
                mdx = "markdown",
                md = "vimwiki",
                mjml = "html",
                sxhkdrc = "sxhkdrc",
                ztst = "ztst",
                rasi = "rasi",
                cr = "crystal",
                ["pre-commit"] = "sh",
                log = "log",
                ms = nroff_ft,
                me = nroff_ft,
                mom = nroff_ft,
                man = nroff_ft,
                cpp = function()
                    b.filetype = "cpp"
                    b.cinoptions = b.cinoptions .. "L0"
                end,
                pdf = function()
                    b.filetype = "pdf"
                    fn.jobstart("zathura " .. '"' .. fn.expand("%") .. '"')
                end,
                h = function()
                    b.filetype = "c"
                    g.c_syntax_for_h = 1
                end,
                json = function()
                    o.shiftwidth = 2
                end
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
                ["fonts.conf"] = "xml"
            },
            pattern = {
                -- [".*&zwj;/etc/foo/.*%.conf"] = {"dosini", {priority = 10}},
                -- [".*/completions/_.*"] = "zsh",
                [".*/git/config"] = "gitconfig",
                [".*/fontconfig/conf%.d/.*"] = "xml",
                [".*/fd/ignore"] = "gitignore",
                ["calcurse-note.*"] = "markdown",
                ["~/.local/share/calcurse/notes/.*"] = "markdown",
                [("%s/calcurse/notes/.*"):format(os.getenv("XDG_DATA_HOME"))] = "markdown",
                [".*sxhkdrc"] = "sxhkdrc",
                ["/tmp/buku%-edit.*"] = "conf",
                ["/tmp/neomutt.*"] = "mail",
                ["README.(%a+)$"] = function(_path, _bufnr, ext)
                    if ext == "md" then
                        return "vimwiki"
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
            }
        }
    )

    -- require("filetype").setup(
    --     {
    --         overrides = {
    --             extensions = {
    --                 sxhkdrc = "sxhkdrc",
    --                 tl = "teal",
    --                 ["pre-commit"] = "sh",
    --                 md = "vimwiki",
    --             },
    --             literal = {
    --                 MyBackupFile = "lua",
    --                 ["yup.lock"] = "yaml",
    --                 [".editorconfig"] = "dosini",
    --                 ["coc-settings.json"] = "jsonc",
    --                 ["Brewfile"] = "ruby"
    --             },
    --             complex = {
    --                 -- [".*/git/config"] = "gitconfig",
    --                 [".*%.env.*"] = "sh",
    --                 [".*ignore"] = "conf",
    --                 ["calcurse-note.*"] = "markdown",
    --                 ["~/.local/share/calcurse/notes/.*"] = "markdown",
    --                 [".*sxhkdrc"] = "sxhkdrc",
    --                 [".*/vimwiki/.*"] = "vimwiki",
    --             },
    --             function_extensions = {
    --                 ["cpp"] = function()
    --                     b.filetype = "cpp"
    --                     -- Remove annoying indent jumping
    --                     b.cinoptions = b.cinoptions .. "L0"
    --                 end,
    --                 ["pdf"] = function()
    --                     b.filetype = "pdf"
    --                     fn.jobstart("zathura " .. '"' .. fn.expand("%") .. '"')
    --                 end,
    --                 ["h"] = function()
    --                     b.filetype = "c"
    --                     g.c_syntax_for_h = 1
    --                 end,
    --                 ["json"] = function()
    --                     -- cmd.syntax("match Comment +//.+$+")
    --                     o.shiftwidth = 2
    --                 end,
    --                 ["ms"] = nroff_ft,
    --                 ["me"] = nroff_ft,
    --                 ["mom"] = nroff_ft,
    --                 -- ["man"] = nroff_ft,
    --             },
    --             function_literal = {},
    --             function_complex = {
    --                 ["*.math_notes/%w+"] = function()
    --                     cmd.iabbrev("$ $$")
    --                 end
    --             },
    --             shebang = {
    --                 -- Set the filetype of files with a dash shebang to sh
    --                 dash = "sh",
    --                 -- zsh = "zsh",
    --                 node = "typescript"
    --             }
    --         }
    --     }
    -- )
end

local function init()
    M.setup()
end

init()

return M
