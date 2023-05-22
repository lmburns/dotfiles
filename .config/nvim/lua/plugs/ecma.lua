---@module 'plugs.ecma'
local M = {}

local shared = require("usr.shared")
local F = shared.F
-- local hl = shared.color
-- local style = require("usr.style")
-- local lazy = require("usr.lazy")
-- local log = require("usr.lib.log")
-- local coc = require("plugs.coc")

local wk = require("which-key")

local mpi = require("usr.api")
local map = mpi.map
local augroup = mpi.augroup

-- ╭──────────────────────────────────────────────────────────╮
-- │                       PackageInfo                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.package_info()
    local pi = F.npcall(require, "package-info")
    if not pi then
        return
    end

    pi.setup({
        colors = {
            up_to_date = "#3C4048", -- Text color for up to date package virtual text
            outdated = "#d19a66",   -- Text color for outdated package virtual text
        },
        icons = {
            enable = true,           -- Whether to display icons
            style = {
                up_to_date = "|  ", -- Icon for up to date packages
                outdated = "|  ", -- Icon for outdated packages
            },
        },
        autostart = true,               -- Whether to autostart when `package.json` is opened
        hide_up_to_date = true,         -- It hides up to date versions when displaying virtual text
        hide_unstable_versions = false, -- It hides unstable versions from version list
        -- `npm`, `yarn`
        package_manager = "yarn",
    })

    augroup(
        "lmb__PackageInfoBindings",
        {
            event = "BufEnter",
            pattern = "package.json",
            command = function(a)
                local bufnr = a.buf
                map("n", "<Leader>cu", F.ithunk(pi.update), {buffer = bufnr})
                map("n", "<Leader>ci", F.ithunk(pi.install), {buffer = bufnr})
                map("n", "<Leader>ch", F.ithunk(pi.change_version), {buffer = bufnr})
                map("n", "<Leader>cr", F.ithunk(pi.reinstall), {buffer = bufnr})

                wk.register({
                    ["<Leader>cu"] = "Update package",
                    ["<Leader>ci"] = "Install package",
                    ["<Leader>ch"] = "Change version",
                    ["<Leader>cr"] = "Reinstall package",
                })
            end,
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Template String                      │
-- ╰──────────────────────────────────────────────────────────╯
function M.template_string()
    local ts = F.npcall(require, "template-string")
    if not ts then
        return
    end

    ts.setup({
        filetypes = {"typescript", "javascript", "typescriptreact", "javascriptreact"},
        jsx_brackets = true, -- should add brackets to jsx attributes
    })
end

return M
