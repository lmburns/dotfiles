local M = {}

require("common.utils")

local nroff_ft = function()
    b.filetype = "nroff"
    w.wrap = true
    b.textwidth = 85
    w.colorcolumn = "+1"
end

function M.setup()
    vim.filetype.add(
        {
            extension = {
                pn = "potion",
                eslintrc = "json",
                prettierrc = "json",
                conf = "conf",
                mdx = "markdown",
                mjml = "html",
                sxhkdrc = "sxhkdrc",
                ztst = "ztst",
                tl = "teal",
                rasi = "rasi",
                ["pre-commit"] = "sh",
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
                ["man"] = nroff_ft
            },
            filename = {
                ["yup.lock"] = "yaml",
                [".editorconfig"] = "dosini",
                ["coc-settings.json"] = "jsonc",
                ["Brewfile"] = "ruby"
            },
            pattern = {
                -- [".*&zwj;/etc/foo/.*%.conf"] = {"dosini", {priority = 10}},
                [".*git/config"] = "gitconfig", -- Included in the plugin
                [".*%.env.*"] = "sh",
                [".*ignore"] = "conf",
                ["calcurse-note.*"] = "markdown",
                ["~/.local/share/calcurse/notes/.*"] = "markdown",
                [".*sxhkdrc"] = "sxhkdrc",
                ["README.(%a+)$"] = function(path, bufnr, ext)
                    if ext == "md" then
                        return "markdown"
                    elseif ext == "rst" then
                        return "rst"
                    end
                end
            }
        }
    )

    require("filetype").setup(
        {
            overrides = {
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
