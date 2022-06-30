local M = {}

local utils = require("common.utils")
local augroup = utils.augroup
-- local map = utils.map
local bmap = utils.bmap
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
