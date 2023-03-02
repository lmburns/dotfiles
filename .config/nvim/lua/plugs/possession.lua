local M = {}

local D = require("dev")
local possession = D.npcall(require, "possession")
if not possession then
    return
end

local log = require("common.log")
local Path = require("plenary.path")

local utils = require("common.utils")
local command = utils.command

local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local uv = vim.loop

local function is_restorable(buffer)
    local n = api.nvim_buf_get_name(buffer)
    return D.buf_is_valid(buffer) and fn.filereadable(n) == 1
end

function M.setup()
    local bufnr = api.nvim_get_current_buf()
    local sess_dir = Path:new(("%s/%s"):format(fn.stdpath("state"), "possession")):absolute()

    possession.setup(
        {
            session_dir = sess_dir,
            silent = true,
            load_silent = true,
            debug = false,
            prompt_no_cr = false,
            autosave = {
                current = false, -- or fun(name): boolean
                tmp = false, -- or fun(): boolean
                tmp_name = uv.cwd():gsub("/", "__"):gsub(":", "++"),
                on_load = false,
                on_quit = false
            },
            commands = {
                save = "PossSave",
                load = "PossLoad",
                close = "PossClose",
                delete = "PossDelete",
                show = "PossShow",
                list = "PossList",
                migrate = "PossMigrate"
            },
            hooks = {
                ---@diagnostic disable-next-line: unused-local
                before_save = function(name)
                    if fn.argc() > 0 then
                        api.nvim_command("%argdel")
                    end
                    if vim.tbl_contains(BLACKLIST_FT, vim.bo[bufnr].ft) then
                        return false
                    end
                    local bufs = api.nvim_list_bufs()
                    for _, value in ipairs(bufs) do
                        if is_restorable(value) then
                            return true
                        end
                    end
                    return false
                end,
                ---@diagnostic disable-next-line: unused-local
                -- after_save = function(name, user_data, aborted)
                --     -- These are warn because I like yellow more than green
                --     log.warn(("Saved: %s"):format(name), {title = "Possession"})
                -- end,
                ---@diagnostic disable-next-line: unused-local
                after_load = function(name, user_data)
                    log.warn(("Loaded: %s"):format(name), {title = "Possession"})
                end
                -- before_load = function(name, user_data)
                -- 	return user_data
                -- end,
            },
            plugins = {
                close_windows = {
                    hooks = {"before_save", "before_load"},
                    preserve_layout = true, -- or fun(win): boolean
                    match = {
                        floating = true,
                        buftype = {},
                        filetype = {},
                        custom = false -- or fun(win): boolean
                    }
                },
                delete_hidden_buffers = {
                    -- "before_load",
                    -- vim.o.sessionoptions:match("buffer") and "before_save",
                    hooks = {},
                    force = false
                },
                nvim_tree = false,
                tabby = false,
                dap = true,
                delete_buffers = false
            }
        }
    )
end

local function init()
    M.setup()

    command(
        "PossSaveCurr",
        function()
            local tmp_name = uv.cwd():gsub("/", "__"):gsub(":", "++")
            cmd("PossSave! " .. tmp_name)
        end,
        {force = true, desc = "Possession save current"}
    )

    command(
        "PossLoadCurr",
        function()
            local tmp_name = uv.cwd():gsub("/", "__"):gsub(":", "++")
            cmd("PossLoad" .. tmp_name)
        end,
        {force = true, desc = "Possession load current"}
    )

    nvim.autocmd.lmb__Possession = {
        event = "VimLeavePre",
        pattern = "*",
        command = function()
            pcall(cmd.PossSaveCurr)
        end,
        once = false
    }

    require("telescope").load_extension("possession")
end

init()

return M
