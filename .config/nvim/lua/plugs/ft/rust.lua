---@module 'plugs.rust'
local M = {}

local F = Rc.F
local augroup = Rc.api.augroup
local coc = require("plugs.coc")
local wk = require("which-key")

local g = vim.g

function M.setup()
    g.rust_recommended_style = 1
    g.rust_bang_comment_leader = 1
    g.rust_fold = 0
    g.rust_conceal = 0
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Crates                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.crates()
    local crates = F.npcall(require, "crates")
    if not crates then
        return
    end

    crates.setup({
        smart_insert = true,
        insert_closing_quote = true,
        avoid_prerelease = true,
        autoload = true,
        autoupdate = true,
        autoupdate_throttle = 250,
        loading_indicator = true,
        date_format = "%Y-%m-%d",
        thousands_separator = ",",
        notification_title = "Crates",
        curl_args = {"-sL", "--retry", "1"},
        disable_invalid_feature_diagnostic = false,
        text = {
            loading = "   Loading",
            version = "   %s",
            prerelease = "   %s",
            yanked = "   %s",
            nomatch = "   No match",
            upgrade = "   %s",
            error = "   Error fetching crate",
        },
        highlight = {
            loading = "CratesNvimLoading",
            version = "CratesNvimVersion",
            prerelease = "CratesNvimPreRelease",
            yanked = "CratesNvimYanked",
            nomatch = "CratesNvimNoMatch",
            upgrade = "CratesNvimUpgrade",
            error = "CratesNvimError",
        },
        popup = {
            autofocus = false,
            hide_on_select = false,
            copy_register = '"',
            style = "minimal",
            border = Rc.style.border,
            show_version_date = false,
            show_dependency_version = true,
            max_height = 30,
            min_width = 20,
            padding = 1,
            keys = {
                hide = {"q", "<esc>"},
                open_url = {"<cr>"},
                select = {"<cr>"},
                select_alt = {"s"},
                toggle_feature = {"<cr>"},
                copy_value = {"yy"},
                goto_item = {"gd", "K", "<C-LeftMouse>"},
                jump_forward = {"<c-i>"},
                jump_back = {"<c-o>", "<C-RightMouse>"},
            },
        },
    })

    augroup(
        "lmb__CratesBindings",
        {
            event = "BufEnter",
            pattern = "Cargo.toml",
            command = function(args)
                local bufnr = args.buf

                local bmap = function(...)
                    Rc.api.bmap(bufnr, ...)
                end

                bmap("n", "<Leader>ca", crates.upgrade_all_crates)
                bmap("n", "<Leader>cu", crates.upgrade_crate)
                bmap("n", "<Leader>ch", crates.open_homepage)
                bmap("n", "<Leader>cr", crates.open_repository)
                bmap("n", "<Leader>cd", crates.open_documentation)
                bmap("n", "<Leader>co", crates.open_crates_io)
                bmap("n", "<Leader>cp", crates.show_dependencies_popup)
                bmap("n", "<Leader>cf", crates.show_features_popup)

                bmap("n", "vd", crates.show_dependencies_popup)
                bmap("n", "vf", crates.show_features_popup)

                local dargs = {wrap = true, float = true}
                bmap("n", "[g", F.ithunk(vim.diagnostic.goto_prev, dargs))
                bmap("n", "]g", F.ithunk(vim.diagnostic.goto_next, dargs))

                wk.register({
                    ["<Leader>ca"] = "Crates: upgrade all",
                    ["<Leader>cu"] = "Crates: upgrade",
                    ["<Leader>ch"] = "Crates: open homepage",
                    ["<Leader>cr"] = "Crates: open repo",
                    ["<Leader>cd"] = "Crates: open docus",
                    ["<Leader>co"] = "Crates: open crates.io",
                    ["<Leader>cp"] = "Crates: view dependencies",
                    ["<Leader>cf"] = "Crates: view features",
                    ["vd"] = "Crates: view dependencies",
                    ["vf"] = "Crates: view features",
                    ["[g"] = "Prev diagnostic",
                    ["]g"] = "Next diagnostic",
                })
            end,
        }
    )
end

local function init()
    M.setup()
end

init()

return M
