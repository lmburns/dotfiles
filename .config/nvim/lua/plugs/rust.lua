local M = {}

local D = require("dev")
local utils = require("common.utils")
local augroup = utils.augroup
local map = utils.map
local bmap = utils.bmap

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
    local crates = D.npcall(require, "crates")
    if not crates then
        return
    end

    crates.setup(
        {
            smart_insert = true,
            insert_closing_quote = true,
            avoid_prerelease = true,
            autoload = true,
            autoupdate = true,
            loading_indicator = true,
            date_format = "%Y-%m-%d",
            thousands_separator = ".",
            notification_title = "Crates",
            disable_invalid_feature_diagnostic = false,
            popup = {
                autofocus = false,
                copy_register = '"',
                style = "minimal",
                border = "none",
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
                    jump_back = {"<c-o>", "<C-RightMouse>"}
                }
            }
        }
    )

    augroup(
        "lmb__CratesBindings",
        {
            event = "BufEnter",
            pattern = "Cargo.toml",
            command = function(args)
                local bufnr = args.buf
                map("n", "<Leader>ca", crates.upgrade_all_crates, {buffer = bufnr})
                map("n", "<Leader>cu", crates.upgrade_crate, {buffer = bufnr})
                map("n", "<Leader>ch", crates.open_homepage, {buffer = bufnr})
                map("n", "<Leader>cr", crates.open_repository, {buffer = bufnr})
                map("n", "<Leader>cd", crates.open_documentation, {buffer = bufnr})
                map("n", "<Leader>co", crates.open_crates_io, {buffer = bufnr})

                map("n", "vd", crates.show_dependencies_popup, {buffer = bufnr})
                map("n", "vv", crates.show_versions_popup, {buffer = bufnr})
                map("n", "vf", crates.show_features_popup, {buffer = bufnr})

                map("n", "[g", vim.diagnostic.goto_prev, {buffer = bufnr})
                map("n", "]g", vim.diagnostic.goto_next, {buffer = bufnr})

                wk.register(
                    {
                        ["<Leader>ca"] = "Upgrade all crates",
                        ["<Leader>cu"] = "Upgrade crate",
                        ["<Leader>ch"] = "Open homepage",
                        ["<Leader>cr"] = "Open repository",
                        ["<Leader>cd"] = "Open documentation",
                        ["<Leader>co"] = "Open crates.io",
                        ["vd"] = "Dependencies popup",
                        ["vv"] = "Version popup",
                        ["vf"] = "Show features"
                    }
                )
            end
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
            command = function()
                -- Rust analyzer really slows things down, so this needs more time
               vim.opt_local.timeoutlen = 500
                local bufnr = nvim.get_current_buf()

                local bmap = function(...)
                    bmap(bufnr, ...)
                end


                bmap("n", "<Leader>t<CR>", "RustTest", {cmd = true})
                bmap("n", "<Leader>h<CR>", ":T cargo clippy<CR>")
                bmap("n", "<Leader>n<CR>", ":T cargo run -q<CR>")
                bmap("n", "<Leader><Leader>n", ":T cargo run -q<space>")
                bmap("n", "<Leader>b<CR>", ":T cargo build -q<CR>")
                bmap("n", "<Leader>r<CR>", ":VT cargo play %<CR>")
                bmap("n", "<Leader>v<CR>", ":T rust-script %<CR>")
                bmap("n", "<Leader>e<CR>", ":T cargo eval %<CR>")

                bmap(
                    "n",
                    "<Leader>re",
                    function()
                        coc.run_command("rust-analyzer.reloadWorkspace", {})
                        coc.run_command("rls.restart", {})
                    end,
                    {desc = "Reload Rust workspace"}
                )

                bmap("n", ";ff", "keepj keepp RustFmt", {cmd = true})
                bmap("v", ";ff", "RustFmtRange", {cmd = true})
            end
        }
    )
end

init()

return M
