local M = {}

require("common.utils")

local nroff_ft = function()
    b.filetype = "nroff"
    w.wrap = true
    b.textwidth = 85
    w.colorcolumn = "+1"
end

function M.setup()
    require("filetype").setup(
        {
            overrides = {
                extensions = {
                    -- Set the filetype of *.pn files to potion
                    pn = "potion",
                    eslintrc = "json",
                    prettierrc = "json",
                    conf = "conf",
                    mdx = "markdown",
                    mjml = "html",
                    sxhkdrc = "sxhkdrc",
                    ztst = "ztst",
                    tl = "teal",
                    ["pre-commit"] = "sh"
                },
                literal = {
                    -- Set the filetype of files named "MyBackupFile" to lua
                    MyBackupFile = "lua",
                    ["yup.lock"] = "yaml",
                    [".editorconfig"] = "dosini",
                    ["coc-settings.json"] = "jsonc"
                },
                complex = {
                    -- Set the filetype of any full filename matching the regex to gitconfig
                    [".*git/config"] = "gitconfig", -- Included in the plugin
                    [".*%.env.*"] = "sh",
                    [".*ignore"] = "conf",
                    ["calcurse-note.*"] = "markdown",
                    ["~/.local/share/calcurse/notes/.*"] = "markdown",
                    [".*sxhkdrc"] = "sxhkdrc"
                },
                -- The same as the ones above except the keys map to functions
                function_extensions = {
                    ["cpp"] = function()
                        b.filetype = "cpp"
                        -- Remove annoying indent jumping
                        b.cinoptions = b.cinoptions .. "L0"
                    end,
                    ["pdf"] = function()
                        b.filetype = "pdf"
                        fn.jobstart("zathura " .. '"' .. fn.expand("%") .. '"')
                    end,
                    ["h"] = function()
                        b.filetype = "c"
                        g.c_syntax_for_h = 1
                    end,
                    ["json"] = function()
                        -- ex.syntax("match Comment +//.+$+")
                        o.shiftwidth = 2
                    end,
                    ["ms"] = nroff_ft,
                    ["me"] = nroff_ft,
                    ["mom"] = nroff_ft,
                    ["man"] = nroff_ft,
                },
                function_literal = {
                    Brewfile = function()
                        cmd("syntax off")
                    end
                },
                function_complex = {
                    ["*.math_notes/%w+"] = function()
                        cmd("iabbrev $ $$")
                    end
                },
                shebang = {
                    -- Set the filetype of files with a dash shebang to sh
                    dash = "sh",
                    -- zsh = "zsh",
                    node = "typescript"
                }
            }
        }
    )
end

local function init()
    M.setup()
end

init()

return M
