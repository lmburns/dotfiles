---@module 'plugs.rust'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local mpi = require("usr.api")
local augroup = mpi.augroup

local style = require("usr.style")
local coc = require("plugs.coc")
local wk = require("which-key")

local g = vim.g

function M.setup()
    -- g.rustfmt_autosave = 1
    -- g.rustfmt_autosave_if_config_present = 1
    g.rust_recommended_style = 1
    g.rust_fold = 1
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
            border = style.current.border,
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
                    mpi.bmap(bufnr, ...)
                end

                bmap("n", "<Leader>ca", crates.upgrade_all_crates)
                bmap("n", "<Leader>cu", crates.upgrade_crate)
                bmap("n", "<Leader>ch", crates.open_homepage)
                bmap("n", "<Leader>cr", crates.open_repository)
                bmap("n", "<Leader>cd", crates.open_documentation)
                bmap("n", "<Leader>co", crates.open_crates_io)

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

    augroup(
        "RustEnv",
        {
            event = "FileType",
            pattern = "rust",
            command = function(args)
                -- Rust analyzer really slows things down, so this needs more time
                vim.opt_local.timeoutlen = 500
                vim.opt_local.comments = {
                    "sO:* -",
                    "mO:*  ",
                    "exO:*/",
                    "s1:/*",
                    "mb:*",
                    "ex:*/",
                    ":///",
                    "://!",
                    "://",
                }

                -- sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,:///,://
                -- s0:/*!,ex:*/,s1:/*,mb:*,:///,://!,://

                local bufnr = args.buf

                local bmap = function(...)
                    mpi.bmap(bufnr, ...)
                end

                bmap("n", "<Leader>t<CR>", "RustTest", {cmd = true})
                bmap("n", "<Leader>h<CR>", ":T cargo clippy<CR>")
                -- bmap("n", "<Leader>n<CR>", ":T cargo run -q<CR>")
                -- bmap("n", "<Leader><Leader>n", ":T cargo run -q<space>")
                -- bmap("n", "<Leader>b<CR>", ":T cargo build -q<CR>")
                -- bmap("n", "<Leader>r<CR>", ":VT cargo play %<CR>")
                -- bmap("n", "<Leader>v<CR>", ":T rust-script %<CR>")
                -- bmap("n", "<Leader>e<CR>", ":T cargo eval %<CR>")

                bmap(
                    "n",
                    "vd",
                    "<Cmd>CocCommand rust-analyzer.moveItemDown<CR>",
                    {desc = "Move item down"}
                )
                bmap(
                    "n",
                    "vu",
                    "<Cmd>CocCommand rust-analyzer.moveItemUp<CR>",
                    {desc = "Move item up"}
                )
                bmap(
                    "n",
                    "<Leader>ex",
                    "<Cmd>CocCommand rust-analyzer.expandMacro<CR>",
                    {desc = "Expand macro"}
                )

                bmap(
                    "n",
                    "<Leader>re",
                    function()
                        coc.run_command("rust-analyzer.reloadWorkspace", {})
                        coc.run_command("rls.restart", {})
                    end,
                    {desc = "Reload Rust workspace"}
                )

                bmap("n", ";ff", "keepj keepp RustFmt", {cmd = true, desc = "Rustfmt: file"})
                bmap("x", ";ff", "RustFmtRange", {cmd = true, desc = "Rustfmt: selected"})
            end,
        }
    )
end

init()

return M
