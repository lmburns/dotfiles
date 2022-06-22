local M = {}

local utils = require("common.utils")
local augroup = utils.augroup
local map = utils.map
local coc = require("plugs.coc")

local g = vim.g

function M.setup()
    -- g.rustfmt_autosave = 1
    -- g.rustfmt_autosave_if_config_present = 1
    g.rust_recommended_style = 1
    g.rust_fold = 1
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

                map("n", "<Leader>t<CR>", "RustTest", {buffer = bufnr, cmd = true})
                map("n", "<Leader>h<CR>", ":T cargo clippy<CR>", {buffer = bufnr})
                map("n", "<Leader>n<CR>", ":T cargo run -q<CR>", {buffer = bufnr})
                map("n", "<Leader><Leader>n", ":T cargo run -q<space>", {buffer = bufnr})
                map("n", "<Leader>b<CR>", ":T cargo build -q<CR>", {buffer = bufnr})
                map("n", "<Leader>r<CR>", ":VT cargo play %<CR>", {buffer = bufnr})
                map("n", "<Leader>v<CR>", ":T rust-script %<CR>", {buffer = bufnr})
                map("n", "<Leader>e<CR>", ":T cargo eval %<CR>", {buffer = bufnr})

                map(
                    "n",
                    "<Leader>re",
                    function()
                        coc.run_command("rust-analyzer.reloadWorkspace", {})
                        coc.run_command("rls.restart", {})
                    end,
                    {buffer = bufnr,  desc = "Reload Rust workspace"}
                )

                map("n", ";ff", "keepj keepp RustFmt", {buffer = bufnr, cmd = true})
                map("v", ";ff", "RustFmtRange", {buffer = bufnr, cmd = true})
            end
        }
    )
end

init()

return M
