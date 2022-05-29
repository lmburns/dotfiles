-- local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local uv = vim.loop

cmd [[set runtimepath=$VIMRUNTIME]]
cmd [[set packpath=/tmp/nvim/site]]

local function prefer_local(url, path)
    if not path then
        local name = url:match("[^/]*$")
        path = "~/projects/nvim/" .. name
    end
    return uv.fs_stat(fn.expand(path)) ~= nil and path or url
end

local package_root = "/tmp/nvim/site/pack"
local install_path = ("%s/packer/start/packer.nvim"):format(package_root)

local function load_plugins()
    require("packer").startup {
        {
            "wbthomason/packer.nvim",
            {
                prefer_local("lf.nvim"),
                requires = {
                    "nvim-lua/plenary.nvim",
                    {
                        "akinsho/toggleterm.nvim",
                        config = function()
                            require("toggleterm").setup(
                                {
                                    size = function(term)
                                        if term.direction == "horizontal" then
                                            return vim.o.lines * 0.4
                                        elseif term.direction == "vertical" then
                                            return vim.o.columns * 0.5
                                        end
                                    end,
                                    open_mapping = [[<c-\>]],
                                    hide_numbers = true,
                                    shade_filetypes = {},
                                    shade_terminals = true,
                                    shading_factor = "1",
                                    start_in_insert = true,
                                    insert_mappings = true,
                                    persist_size = true,
                                    shell = vim.o.shell,
                                    direction = "float",
                                    -- direction = "horizontal",
                                    close_on_exit = true,
                                    float_opts = {
                                        border = "rounded",
                                        width = math.floor(vim.o.columns * 0.85),
                                        height = math.floor(vim.o.lines * 0.8),
                                        winblend = 4,
                                        highlights = {border = "Normal", background = "Normal"}
                                    }
                                }
                            )
                        end
                    }
                }
            }
        },
        config = {
            package_root = package_root,
            compile_path = ("%s/plugin/packer_compiled.lua"):format(install_path),
            display = { non_interactive = true },
        }
    }
end

_G.load_config = function()
    vim.g.lf_netrw = 1

    require("lf").setup(
        {
            escape_quit = false,
            border = "rounded"
        }
    )

    vim.keymap.set("n", "<C-o>", ":Lf<CR>")
end

if fn.isdirectory(install_path) == 0 then
    print("Installing minimal setup")
    fn.system {"git", "clone", "--depth=1", "https://github.com/wbthomason/packer.nvim", install_path}
end

load_plugins()
require("packer").sync()

cmd [[autocmd User PackerComplete ++once echo "Ready!" | lua load_config()]]
