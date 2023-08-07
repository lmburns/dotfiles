---@module 'plugs.rust'
local M = {}

local F = Rc.F
local augroup = Rc.api.augroup
-- local coc = require("plugs.coc")
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
        max_parallel_requests = 80,
        open_programs = {"handlr open", "xdg-open"},
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
            show_version_date = true,
            show_dependency_version = true,
            max_height = 45,
            min_width = 20,
            padding = 1,
            text = {
                title = " %s",
                pill_left = "",
                pill_right = "",
                description = "%s",
                created_label = " created        ",
                created = "%s",
                updated_label = " updated        ",
                updated = "%s",
                downloads_label = " downloads      ",
                downloads = "%s",
                homepage_label = " homepage       ",
                homepage = "%s",
                repository_label = " repository     ",
                repository = "%s",
                documentation_label = " documentation  ",
                documentation = "%s",
                crates_io_label = " crates.io      ",
                crates_io = "%s",
                categories_label = " categories     ",
                keywords_label = " keywords       ",
                version = "  %s",
                prerelease = " %s",
                yanked = " %s",
                version_date = "  %s",
                feature = "  %s",
                enabled = " %s",
                transitive = " %s",
                normal_dependencies_title = " Dependencies",
                build_dependencies_title = " Build dependencies",
                dev_dependencies_title = " Dev dependencies",
                dependency = "  %s",
                optional = " %s",
                dependency_version = "  %s",
                loading = "  ",
            },
            highlight = {
                title = "CratesNvimPopupTitle",
                pill_text = "CratesNvimPopupPillText",
                pill_border = "CratesNvimPopupPillBorder",
                description = "CratesNvimPopupDescription",
                created_label = "CratesNvimPopupLabel",
                created = "CratesNvimPopupValue",
                updated_label = "CratesNvimPopupLabel",
                updated = "CratesNvimPopupValue",
                downloads_label = "CratesNvimPopupLabel",
                downloads = "CratesNvimPopupValue",
                homepage_label = "CratesNvimPopupLabel",
                homepage = "CratesNvimPopupUrl",
                repository_label = "CratesNvimPopupLabel",
                repository = "CratesNvimPopupUrl",
                documentation_label = "CratesNvimPopupLabel",
                documentation = "CratesNvimPopupUrl",
                crates_io_label = "CratesNvimPopupLabel",
                crates_io = "CratesNvimPopupUrl",
                categories_label = "CratesNvimPopupLabel",
                keywords_label = "CratesNvimPopupLabel",
                version = "CratesNvimPopupVersion",
                prerelease = "CratesNvimPopupPreRelease",
                yanked = "CratesNvimPopupYanked",
                version_date = "CratesNvimPopupVersionDate",
                feature = "CratesNvimPopupFeature",
                enabled = "CratesNvimPopupEnabled",
                transitive = "CratesNvimPopupTransitive",
                normal_dependencies_title = "CratesNvimPopupNormalDependenciesTitle",
                build_dependencies_title = "CratesNvimPopupBuildDependenciesTitle",
                dev_dependencies_title = "CratesNvimPopupDevDependenciesTitle",
                dependency = "CratesNvimPopupDependency",
                optional = "CratesNvimPopupOptional",
                dependency_version = "CratesNvimPopupDependencyVersion",
                loading = "CratesNvimPopupLoading",
            },
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
        src = {
            coq = {enabled = false, name = "Crates"},
            insert_closing_quote = true,
            text = {
                prerelease = "  pre-release ",
                yanked = "  yanked ",
            },
        },
        null_ls = {enabled = false, name = "Crates"},
        on_attach = function(_bufnr) end,
    })

    augroup(
        "lmb__CratesBindings",
        {
            event = "BufEnter",
            pattern = "Cargo.toml",
            command = function(a)
                local bufnr = a.buf

                local bmap = function(...)
                    Rc.api.bmap(bufnr, ...)
                end

                bmap("n", "<Leader>c!", crates.toggle)
                bmap("n", "<Leader>c,", crates.reload)

                bmap("n", "<Leader>cu", crates.upgrade_crate)
                bmap("n", "<Leader>ca", crates.upgrade_all_crates)
                bmap("v", "<Leader>cu", crates.upgrade_crates)
                bmap("n", "<Leader>cU", crates.update_crate)
                bmap("n", "<Leader>cA", crates.update_all_crates)
                bmap("v", "<Leader>cU", crates.update_crates)

                bmap("n", "<Leader>ch", crates.open_homepage)
                bmap("n", "<Leader>cr", crates.open_repository)
                bmap("n", "<Leader>cd", crates.open_documentation)
                bmap("n", "<Leader>co", crates.open_crates_io)

                bmap("n", "<Leader>cv", crates.show_versions_popup)
                bmap("n", "<Leader>cp", crates.show_dependencies_popup)
                bmap("n", "<Leader>cf", crates.show_features_popup)
                bmap("n", "<Leader>cc", crates.focus_popup)
                bmap("n", "<Leader>c;", crates.focus_popup)

                bmap("n", "<Leader>ce", crates.expand_plain_crate_to_inline_table)
                bmap("n", "<Leader>cE", crates.extract_crate_into_table)

                bmap("n", "vs", crates.show_versions_popup)
                bmap("n", "vd", crates.show_dependencies_popup)
                bmap("n", "vf", crates.show_features_popup)

                local dargs = {wrap = true, float = true}
                bmap("n", "[g", F.ithunk(vim.diagnostic.goto_prev, dargs))
                bmap("n", "]g", F.ithunk(vim.diagnostic.goto_next, dargs))

                wk.register({
                    ["<Leader>c!"] = "Crates: toggle",
                    ["<Leader>c,"] = "Crates: reload",
                    ["<Leader>cu"] = "Crates: upgrade",
                    ["<Leader>ca"] = "Crates: upgrade all",
                    ["<Leader>cU"] = "Crates: update",
                    ["<Leader>cA"] = "Crates: update all",
                    ["<Leader>ch"] = "Crates: open homepage",
                    ["<Leader>cr"] = "Crates: open repo",
                    ["<Leader>cd"] = "Crates: open docs.rs",
                    ["<Leader>co"] = "Crates: open crates.io",
                    ["<Leader>cv"] = "Crates: view versions",
                    ["<Leader>cp"] = "Crates: view dependencies",
                    ["<Leader>cf"] = "Crates: view features",
                    ["<Leader>cc"] = "Crates: focus popup",
                    ["<Leader>c;"] = "Crates: focus popup",
                    ["<Leader>ce"] = "Crates: extract to inline table",
                    ["<Leader>cE"] = "Crates: extract to table",
                    ["vs"] = "Crates: view versions",
                    ["vd"] = "Crates: view dependencies",
                    ["vf"] = "Crates: view features",
                    ["[g"] = "Prev diagnostic",
                    ["]g"] = "Next diagnostic",
                }, {mode = "n"})

                wk.register({
                    ["<Leader>cu"] = "Crates: upgrade",
                    ["<Leader>cU"] = "Crates: update",
                }, {mode = "v"})
            end,
        }
    )
end

local function init()
    M.setup()
end

init()

return M
